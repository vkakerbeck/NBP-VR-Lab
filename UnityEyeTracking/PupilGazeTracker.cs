// Pupil Gaze Tracker service
// Written by MHD Yamen Saraiji. Modified by Viviane Kakerbeck.
// original code by MHD Yamen Saraiji: https://github.com/mrayy
//To adapt to your own project search this document for "XX" and set all variables specified
//at the found locations to your own project variables.

//Import dependencies
using UnityEngine;
using System.Collections.Generic;
using System.Threading;
using System.IO;
using System;
using NetMQ;
using NetMQ.Sockets;
using MsgPack.Serialization;
using UnityEngine.UI;
//Define namespace
namespace Pupil
{
	//Pupil data types based on Yuta Itoh sample hosted in https://github.com/pupil-labs/hmd-eyes
	[Serializable]
	public class ProjectedSphere
	{
		public double[] axes = new double[] {0,0};
		public double angle;
		public double[] center = new double[] {0,0};
	}
	[Serializable]
	public class Sphere
	{
		public double radius;
		public double[] center = new double[] {0,0,0};
	}
	[Serializable]
	public class Circle3d
	{
		public double radius;
		public double[] center = new double[] {0,0,0};
		public double[] normal = new double[] {0,0,0};
	}
	[Serializable]
	public class Ellipse
	{
		public double[] axes = new double[] {0,0};
		public double angle;
		public double[] center = new double[] {0,0};
	}
	[Serializable]
	public class PupilData3D
	{
		public double diameter;
		public double confidence;
		public ProjectedSphere projected_sphere = new ProjectedSphere();
		public double theta;
		public int model_id;
		public double timestamp;
		public double model_confidence;
		public string method;
		public double phi;
		public Sphere sphere = new Sphere();
		public double diameter_3d;
		public double[] norm_pos = new double[] { 0, 0, 0 };
		public int id;
		public double model_birth_timestamp;
		public Circle3d circle_3d = new Circle3d();
		public Ellipse ellipese = new Ellipse();
	}
}
public class PupilGazeTracker : MonoBehaviour
{
    //Individual Variables -> XX: Tweek for your project-------------------------------
    public float RayDistance;//Length of gaze vector -> can be set in inspector
    public float Timeleft = 1800.0f;//Length of session in seconds
    float updateInterval = 0.033f;//Speed with which recordings are made -> 30 recordings per second
    float VPNumLen = 4;//Intended number of diggets in VP Number
    Vector3 StartPos = new Vector3(455, 0.2f, 735);//Start position of player from where on recordings start (after initial training and accomodation to VR)
    string TrackingPath = "D:/v.kakerbeck/Tracking/";//Path to the folder where you want to save your tracking results
    public string ServerIP = "";//get from Pupil Capture window -> Can be set in Inspector
    public int ServicePort = 50020;//Also find in Pupil Capture
    public int DefaultCalibrationCount = 120;
    public int SamplesCount = 4;
    public float CanvasWidth = 640;
    public float CanvasHeight = 480;
    //General Variables----------------------------------------------------------------
    public string VPNumIn = "";//Enrty of input field in GUI
    string VPNum = "";//Set VP Number -> Used for saving
    //Gameobject references in unity scene -> will be assigned in Start()---------------
    GameObject eye;
    GameObject player;
    GameObject spheres;
    GameObject Gaze2D;
    GameObject Marker;
    GameObject EyeBox;
    Camera cam;
    Renderer rend;
    Canvas c;
    recorder rec;
    private Transform HeadsetCameraRig;
    //Eye Data----------------------------------------------------------------------------------
    EyeGazeRenderer[] gazerend;
    static PupilGazeTracker _Instance;
    RequestSocket _requestSocket;
    EyeData leftEye;
    EyeData rightEye;
    Vector2 _eyePos;
    Thread _serviceThread;
    Pupil.PupilData3D _pupilData;
    float CenterX;//2D Gaze position
    float CenterY;
    //Bools for checking status-----------------------------------------------------------------------------
    public bool valStarted = false;//3D Validation started?
    public bool val2Started = false;//2D Validation started?
    bool pointTaken;//Reference point recorded for validation?
    public bool paused = false;//Session paused?
    //public bool Pupilrecording = false; //XX: Uncomment this if you want to record through Pupil Labs (fps independent of Unity) 
    public bool EyesOpen = true;//Eyes Open? -> If confidence of eye tracker >0.5
    public bool trainingStarted = false;//Session started? -> Puts Player to start position and starts all recordings
    bool _isDone = false;
    bool _isconnected = false;
    //Variables for Calibration & other eye tracking related things-----------------------------------------
    Vector2[] _calibPoints;
    int _calibSamples;
    int _currCalibPoint = 0;
    int _currCalibSamples = 0;
    int _gazeFPS = 0;
    int _currentFps = 0;
    DateTime _lastT;
    object _dataLock;
    //Variables for Validation------------------------------------------------------------------------------
    Vector2[] valPoints;//Points used for validation
    int i;//counter for validation
    Vector3 groundTruth;//Ground truth in validation
    Vector3 ActualP;//Gaze given from eye tracker -> for validation
    Vector3 point3D;//Target point in Validation
    float avg;
    int numVal3 = 0;
    int numVal2 = 0;
    float LastValAvg = 0;
    float StartT;//Timing variables used for Validation
    float StartTV;
    //Lists for Values -> Usually saved to file later on---------------------------------------------------
    List<string> Gazes = new List<string>();//list of 2D eye positions
    List<string> Boxposs = new List<string>();//list of 3D Box Positions
    List<float> angles = new List<float>();//degrees of difference between ground truth and eye tracking data for validation
    List<double> confidences = new List<double>();//Used in Validation to wait until eye detected well
    List<Dictionary<string, object>> _calibrationData = new List<Dictionary<string, object>>();

    public static PupilGazeTracker Instance
    {
        get {
            if (_Instance == null) {
                _Instance = new GameObject("PupilGazeTracker").AddComponent<PupilGazeTracker>();
            }
            return _Instance;
        }
    }
    class MovingAverage
    {
        List<float> samples = new List<float>();
        int length = 5;

        public MovingAverage(int len)
        {
            length = len;
        }
        public float AddSample(float v)
        {
            samples.Add(v);
            while (samples.Count > length) {
                samples.RemoveAt(0);
            }
            float s = 0;
            for (int i = 0; i < samples.Count; ++i)
                s += samples[i];

            return s / (float)samples.Count;
        }
    }
    class EyeData
    {
        MovingAverage xavg;
        MovingAverage yavg;

        public EyeData(int len)
        {
            xavg = new MovingAverage(len);
            yavg = new MovingAverage(len);
        }
        public Vector2 gaze = new Vector2();
        public Vector2 AddGaze(float x, float y)
        {
            gaze.x = xavg.AddSample(x);
            gaze.y = yavg.AddSample(y);
            return gaze;
        }
    }
    public delegate void OnCalibrationStartedDeleg(PupilGazeTracker manager);
    public delegate void OnCalibrationDoneDeleg(PupilGazeTracker manager);
    public delegate void OnEyeGazeDeleg(PupilGazeTracker manager);
    public delegate void OnCalibDataDeleg(PupilGazeTracker manager, float x, float y);

    public event OnCalibrationStartedDeleg OnCalibrationStarted;
    public event OnCalibrationDoneDeleg OnCalibrationDone;
    public event OnEyeGazeDeleg OnEyeGaze;
    public event OnCalibDataDeleg OnCalibData;

    [SerializeField]
    Dictionary<string, object>[] _CalibrationPoints
    {
        get { return _calibrationData.ToArray(); }
    }
    public int FPS
    {
        get { return _currentFps; }
    }
    enum EStatus
    {
        Idle,
        ProcessingGaze,
        Calibration
    }
    EStatus m_status = EStatus.Idle;
    public enum GazeSource
    {
        LeftEye,
        RightEye,
        BothEyes
    }
    //different ways to access the eye position
    public Vector2 NormalizedEyePos //normalized eye position, x and y value
    {
        get { return _eyePos; }
    }
    public Vector2 EyePos//normalizes eye pos calculated in unity coordinate system and adapted to canvas size
    {
        get { return new Vector2((_eyePos.x - 0.5f) * CanvasWidth, (_eyePos.y - 0.5f) * CanvasHeight); }
    }
    public Vector2 LeftEyePos//short way to access left eyes gaze
    {
        get { return leftEye.gaze; }
    }
    public Vector2 RightEyePos//short way to access right eyes gaze
    {
        get { return rightEye.gaze; }
    }
    public Vector2 GetEyeGaze(GazeSource s)
    {
        if (s == GazeSource.RightEye)
            return RightEyePos;
        if (s == GazeSource.LeftEye)
            return LeftEyePos;
        return NormalizedEyePos;
    }
    public double Confidence//get confidence of pupil data
    {
        get
        {
            if (_pupilData == null) { return 0; }
            return _pupilData.confidence;
        }
    }
    public PupilGazeTracker()
    {
        _Instance = this;
    }
    void Start()
    {
        if (PupilGazeTracker._Instance == null)
            PupilGazeTracker._Instance = this;
        leftEye = new EyeData(SamplesCount);
        rightEye = new EyeData(SamplesCount);
        _dataLock = new object();
        _serviceThread = new Thread(NetMQClient);
        _serviceThread.Start();
        //Find all GameObjects needed-> XX: Change to the names of corresponding Objects in your scene
        EyeBox = GameObject.Find("EyeCube");//Reference Object for calculating 3D gaze -> child object of Camera(eye)
        eye = GameObject.Find("Camera (eye)");//Eye camera
        rec = eye.GetComponent<recorder>();//recorder script attached to Camera(eye)
        cam = eye.GetComponent<Camera>();//Camera of VR Player
        player = GameObject.Find("[CameraRig]");//Parent object of Everything Player related (Camera, Reference object,...)
        rend = EyeBox.GetComponent<Renderer>();//Renderer of reference obejct (to make it invisible)
        Gaze2D = GameObject.Find("Center");//Image of Target for Calibration and Validation
        Marker = GameObject.Find("Calib");//Image for gaze markers
        gazerend = FindObjectsOfType<EyeGazeRenderer>();
        c = GameObject.Find("Canvas").GetComponentInParent<Canvas>();//Canvas on which targets are shown
        Transform eyeCamera = GameObject.FindObjectOfType<SteamVR_Camera>().GetComponent<Transform>();//Transform of camera
        HeadsetCameraRig = eyeCamera.parent;//parent object of camera
    }
    void OnDestroy()
    {
        if (m_status == EStatus.Calibration)
            StopCalibration();
        _isDone = true;
        _serviceThread.Join();
    }
    NetMQMessage _sendRequestMessage(Dictionary<string, object> data)
    {
        NetMQMessage m = new NetMQMessage();
        m.Append("notify." + data["subject"]);

        using (var byteStream = new MemoryStream()) {
            var ctx = new SerializationContext();
            ctx.CompatibilityOptions.PackerCompatibilityOptions = MsgPack.PackerCompatibilityOptions.None;
            var ser = MessagePackSerializer.Get<object>(ctx);
            ser.Pack(byteStream, data);
            m.Append(byteStream.ToArray());
        }
        _requestSocket.SendMultipartMessage(m);

        NetMQMessage recievedMsg;
        recievedMsg = _requestSocket.ReceiveMultipartMessage();
        return recievedMsg;
    }//used to send messages to pupil labs
    public float GetPupilTimestamp()//Use this to synchronize with pupil recordings
    {
        _requestSocket.SendFrame("t");
        NetMQMessage recievedMsg = _requestSocket.ReceiveMultipartMessage();
        return float.Parse(recievedMsg[0].ConvertToString());
    }
    void NetMQClient()//connect and communicate via netMQ
    {
        string IPHeader = ">tcp://" + ServerIP + ":";
        var timeout = new System.TimeSpan(0, 0, 1); //1sec
        AsyncIO.ForceDotNet.Force();
        NetMQConfig.ManualTerminationTakeOver();
        NetMQConfig.ContextCreate(true);

        string subport = "";
        Debug.Log("Connect to the server: " + IPHeader + ServicePort + ".");
        _requestSocket = new RequestSocket(IPHeader + ServicePort);

        _requestSocket.SendFrame("SUB_PORT");
        _isconnected = _requestSocket.TryReceiveFrameString(timeout, out subport);
        //_sendRequestMessage(new Dictionary<string, object> { { "subject", "start_plugin" }, { "name", "Fixation_Detector_3D" } });
        _lastT = DateTime.Now;

        if (_isconnected)
        {
            StartProcess();
            var subscriberSocket = new SubscriberSocket(IPHeader + subport);
            subscriberSocket.Subscribe("gaze"); //subscribe for gaze data
            subscriberSocket.Subscribe("notify."); //subscribe for all notifications
            _setStatus(EStatus.ProcessingGaze);
            var msg = new NetMQMessage();
            while (_isDone == false)
            {
                _isconnected = subscriberSocket.TryReceiveMultipartMessage(timeout, ref (msg));
                if (_isconnected)
                {
                    try
                    {
                        string msgType = msg[0].ConvertToString();
                        if (msgType == "gaze")
                        {
                            var message = MsgPack.Unpacking.UnpackObject(msg[1].ToByteArray());
                            MsgPack.MessagePackObject mmap = message.Value;
                            lock (_dataLock)
                            {
                                _pupilData = JsonUtility.FromJson<Pupil.PupilData3D>(mmap.ToString());
                                if (_pupilData.confidence > 0.5f)
                                {
                                    EyesOpen = true;
                                    OnPacket(_pupilData);
                                }
                                else
                                {
                                    EyesOpen = false;
                                }
                            }
                        }
                    }
                    catch
                    {
                        //	Debug.Log("Failed to unpack.");
                    }
                }
                else
                {
                    //	Debug.Log("Failed to receive a message.");
                    Thread.Sleep(500);
                }
            }

            StopProcess();
            subscriberSocket.Close();
        }
        else
        {
            Debug.Log("Failed to connect the server.");
        }
        _requestSocket.Close();
        Debug.Log("ContextTerminate.");
        NetMQConfig.ContextTerminate();
    }
    void _setStatus(EStatus st)//set callibration status
    {
        if (st == EStatus.Calibration)
        {
            _calibrationData.Clear();
            _currCalibPoint = 0;
            _currCalibSamples = 0;
        }

        m_status = st;
    }
    public void StartProcess()//start eye process
    {
        _sendRequestMessage(new Dictionary<string, object> { { "subject", "eye_process.should_start.0" }, { "eye_id", 0 } });
        _sendRequestMessage(new Dictionary<string, object> { { "subject", "eye_process.should_start.1" }, { "eye_id", 1 } });
    }
    public void StopProcess()//Stop eye process
    {
        _sendRequestMessage(new Dictionary<string, object> { { "subject", "eye_process.should_stop" }, { "eye_id", 0 } });
        _sendRequestMessage(new Dictionary<string, object> { { "subject", "eye_process.should_stop" }, { "eye_id", 1 } });
    }
    public void StartPupilServiceRecording(string path)//start the recording and save it in the given path
    {
        _sendRequestMessage(new Dictionary<string, object> { { "subject", "recording.should_start" }, { "session_name", path } });
    }
    public void StopPupilServiceRecording()
    {
       _sendRequestMessage(new Dictionary<string, object> { { "subject", "recording.should_stop" } });
    }
    //Calibration-------------------------------------------------------------------------------------------------------------
    public void StartCalibration() //calibrate using 17 points and 120 samples for each target
    {
        StartCalibration(new Vector2[] {new Vector2 (0.5f, 0.5f),
            new Vector2 (0.2f, 0.2f), new Vector2 (0.2f, 0.5f),
            new Vector2 (0.2f, 0.8f), new Vector2 (0.5f, 0.8f), new Vector2 (0.8f, 0.8f),
            new Vector2 (0.8f, 0.5f), new Vector2 (0.8f, 0.2f), new Vector2 (0.5f, 0.2f),
            new Vector2(0.3f,0.3f), new Vector2(0.3f,0.5f), new Vector2(0.3f,0.7f), new Vector2(0.5f,0.7f),
            new Vector2(0.7f,0.7f),new Vector2(0.7f,0.5f),new Vector2(0.7f,0.3f),new Vector2(0.5f,0.3f)
        }, DefaultCalibrationCount);
    }
    public void StartCalibration(Vector2[] calibPoints, int samples)
    {
        _calibPoints = calibPoints;
        _calibSamples = samples;

        _sendRequestMessage(new Dictionary<string, object> { { "subject", "start_plugin" }, { "name", "HMD_Calibration" } });
        _sendRequestMessage(new Dictionary<string, object> { { "subject", "calibration.should_start" }, { "hmd_video_frame_size", new float[] { 1000, 1000 } }, { "outlier_threshold", 35 } });
        _setStatus(EStatus.Calibration);

        if (OnCalibrationStarted != null)
            OnCalibrationStarted(this);
        rec.isRec = false;
    }
    public void StopCalibration()
    {
        _sendRequestMessage(new Dictionary<string, object> { { "subject", "calibration.should_stop" } });
        if (OnCalibrationDone != null)
            OnCalibrationDone(this);
        _setStatus(EStatus.ProcessingGaze);
        rec.isRec = true;
    }
    //Validation--------------------------------------------------------------------------------------------------------------
    public void StartValidation2D(Vector2[] validPoints)//start 2D validation with given validation points given in PupilCalibMarker
    {
        val2Started = true;
        StartT = Time.time;
        StartTV = Time.time - 3;
        valPoints = validPoints;
        rec.isRec = false;
        for (int i = 1; i< 7; i++) {
            confidences.Add(0); }        
    }
    public void validation2D()//procedure for showing targets in 2D plane and calculating visual degree of error
    {
        if (StartT + 3 <= Time.time && i <= valPoints.Length)
        {
            Vector2 point = valPoints[i];
            point3D = new Vector3((point[0] - 0.5f) * c.pixelRect.width, (point[1] - 0.5f) * c.pixelRect.height, 0);
            _CalibData(valPoints[i].x, valPoints[i].y);
            i = i + 1;
            StartT = Time.time;
            StartTV = Time.time;
            pointTaken = false;
            Marker.transform.localPosition = point3D;
            confidences.Add(_pupilData.confidence);
        }
        if (StartTV + 2 <= Time.time && i <= valPoints.Length && pointTaken == false && i >= 1)
        {
            if (confidences[confidences.Count - 1] > 0.9 && confidences[confidences.Count - 2] > 0.9 && confidences[confidences.Count - 3] > 0.9 && confidences[confidences.Count - 4] > 0.9 && confidences[confidences.Count - 5] > 0.9 && confidences[confidences.Count - 6] > 0.9)
            {
                pointTaken = true;
                Vector3 refgaze = Gaze2D.transform.position;
                Vector3 GT = (Marker.transform.position - player.transform.position).normalized;//normalized ground truth vector
                Vector3 AV = (refgaze - player.transform.position).normalized;//normalized reference vector given by the eye tracker
                float angleR = Mathf.Acos(Vector3.Dot(GT, AV));//calculate visual angle between ground truth vector and reference vector in radians
                float angleD = angleR * (180.0f / (float)Math.PI);//convert radians into degree
                angles.Add(angleD);
            }
            else { StartTV = StartTV + Time.deltaTime; StartT = StartT + Time.deltaTime; confidences.Add(_pupilData.confidence); }
        }
        if (i == valPoints.Length && pointTaken == true)
        {
            Vector2 point = valPoints[0];
            point3D = new Vector3((point[0] - 0.5f) * c.pixelRect.width, (point[1] - 0.5f) * c.pixelRect.height, 0);
            Marker.transform.localPosition = point3D;
            StopValidation2D();
        }
    }
    public void StopValidation2D()
    {
        val2Started = false;
        float sum = 0;
        rec.isRec = true;
        foreach (float d in angles)
        {
            sum = sum + d;
            avg = sum / angles.Count;
        }
        numVal2 = numVal2 + 1;
        String pathVal2 = String.Format(@"D:\v.kakerbeck\Tracking\Validation\validation2D_" + VPNum.ToString() + "_" + numVal2.ToString() + ".txt");
        LastValAvg = avg;
        using (StreamWriter validation = new StreamWriter(@pathVal2))
        {
            foreach (var value in angles)
            {
                validation.WriteLine(value);
            }
            validation.WriteLine("Average 2D Validation:");
            validation.WriteLine(avg);
            validation.WriteLine(Timeleft);
        }
        angles.Clear();
        avg = 0;
        cam.cullingMask = -1;
        i = 0;
        foreach (EyeGazeRenderer gr in gazerend) {
            gr.GetComponent<Image>().transform.position = new Vector2(0, 0);
            gr.GetComponent<Image>().enabled = false;
        }
    }
    public void StartValidation3D(Vector2[] validPoints)//start 3D validation with given validation points given in PupilCalibMarker
    {
        valStarted = true;
        StartT = Time.time;
        StartTV = Time.time-3;
        valPoints = validPoints;
        spheres = new GameObject("spheres");
        i = 0;
        rec.isRec = false;
    }
    public void validation3D()//procedure for showing targets in 3D space and calculating visual degree of error
    {
        //Show Validation target every 3 seconds at positions handed into the StartValidation method
        if (StartT + 3 <= Time.time && i <= valPoints.Length)
        {
            Vector2 point = valPoints[i];
            i = i + 1;
            rend.enabled = false;
            RaycastHit hit;
            EyeBox.transform.localPosition = new Vector3((point[0] - 0.5f) * RayDistance / 2, (point[1] - 0.5f) * RayDistance / 2, RayDistance / 2);
            Ray Targets = new Ray(player.transform.position, (EyeBox.transform.position - player.transform.position));
            Color color = new Color(255, 1, 1, 1);
            if (Physics.Raycast(Targets, out hit))//Ray hits object
            {
                GameObject sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                sphere.transform.position = hit.point;
                sphere.transform.localScale = new Vector3(0.5f, 0.5f, 0.5f);
                rend = sphere.GetComponent<Renderer>();
                rend.material.color = color;
                Collider c = sphere.GetComponent<Collider>();
                c.enabled = false;
                groundTruth = sphere.transform.position;
                sphere.transform.SetParent(spheres.transform);
            }
            else//ray doesn't hit object -> show it at position if EyeBox (distance of 50) in the sky
            {
                GameObject sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                sphere.transform.position = EyeBox.transform.position;
                sphere.transform.localScale = new Vector3(0.5f, 0.5f, 0.5f);
                rend = sphere.GetComponent<Renderer>();
                rend.material.color = color;
                Collider c = sphere.GetComponent<Collider>();
                c.enabled = false;
                groundTruth = sphere.transform.position;
                sphere.transform.SetParent(spheres.transform);
            }
            StartT = Time.time;
            StartTV = Time.time;
            pointTaken = false;
        }
        //take reference point from eye tracker -> where does the eye tracker think the subject is looking?
        //records 2 seconds after target presentation if confidence of eye tracker is >0.5. Otherwise it waits until condition is met
        if (StartTV + 2 <= Time.time && i <= valPoints.Length && pointTaken == false && i >= 1)
        {
            if (EyesOpen)
            {
                pointTaken = true;
                RaycastHit hit;
                EyeBox.transform.localPosition = new Vector3((CenterX - 0.5f) * RayDistance / 2, (CenterY - 0.5f) * RayDistance / 2, RayDistance / 2);
                Ray Comp = new Ray(player.transform.position, (EyeBox.transform.position - player.transform.position));
                //Color color = new Color(1, 255, 100, 255);
                if (Physics.Raycast(Comp, out hit))
                {
                    GameObject sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                    sphere.transform.position = hit.point;
                    sphere.transform.localScale = new Vector3(0.5f, 0.5f, 0.5f);
                    Renderer rend = sphere.GetComponent<Renderer>();
                    //rend.material.color = color;
                    rend.enabled = false;
                    Collider c = sphere.GetComponent<Collider>();
                    c.enabled = false;
                    ActualP = sphere.transform.position;
                    sphere.transform.SetParent(spheres.transform);
                }
                else
                {
                    GameObject sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                    sphere.transform.position = EyeBox.transform.position;
                    sphere.transform.localScale = new Vector3(0.5f, 0.5f, 0.5f);
                    Renderer rend = sphere.GetComponent<Renderer>();
                    //rend.material.color = color;
                    rend.enabled = false;
                    Collider c = sphere.GetComponent<Collider>();
                    c.enabled = false;
                    ActualP = sphere.transform.position;
                    sphere.transform.SetParent(spheres.transform);
                }
                Vector3 GT = (groundTruth - player.transform.position).normalized;//normalized ground truth vector
                Vector3 AV = (ActualP - player.transform.position).normalized;//normalized reference vector given by the eye tracker
                float angleR = Mathf.Acos(Vector3.Dot(GT, AV));//calculate visual angle between ground truth vector and reference vector in radians
                float angleD = angleR * (180.0f / (float)Math.PI);//convert radians into degree
                angles.Add(angleD);
                //eucledian distance between the two hit points (bigger when points are shown further apart or close to object boundary
                //distance = (float)Math.Sqrt(Math.Pow((groundTruth[0] - ActualP[0]), 2) + Math.Pow((groundTruth[1] - ActualP[1]), 2) + Math.Pow((groundTruth[2] - ActualP[2]), 2));
            }
            else { StartTV = StartTV + Time.deltaTime; StartT = StartT + Time.deltaTime; }//prolong time if detection confidence is not high enough
            if (i == valPoints.Length) StopValidation3D();
        }
    }
    public void StopValidation3D()
    {
        valStarted = false;
        Destroy(spheres);
        rec.isRec = true;
        float sum = 0;
        foreach (float d in angles){
            sum = sum + d;
            avg = sum / angles.Count;
        }
        numVal3 = numVal3 + 1;
        String pathVal3 = String.Format (@"D:\v.kakerbeck\Tracking\Validation\validation3D_"+VPNum.ToString()+"_"+ numVal3.ToString()+".txt");
        LastValAvg = avg;
        using (StreamWriter validation = new StreamWriter(@pathVal3))
        {
            foreach (var value in angles)
            {
                validation.WriteLine(value);
            }
            validation.WriteLine("Average 3D Validation:");
            validation.WriteLine(avg);
            validation.WriteLine(Timeleft);
        }
        angles.Clear();
        avg = 0;
        cam.cullingMask = -1;
        i = 0;
    }
    //------------------------------------------------------------------------------------------------------------------------
    void _CalibData(float x, float y)
    {
        if (OnCalibData != null)
            OnCalibData(this, x, y);
    }
    void OnPacket(Pupil.PupilData3D data)//process new pupil data
    {
        //add new frame
        _gazeFPS++;
        var ct = DateTime.Now;
        if ((ct - _lastT).TotalSeconds > 1)
        {
            _lastT = ct;
            _currentFps = _gazeFPS;
            _gazeFPS = 0;
        }
        if (m_status == EStatus.ProcessingGaze) { //gaze processing stage
            float x, y;
            x = (float)data.norm_pos[0];
            y = (float)data.norm_pos[1];
            _eyePos.x = (leftEye.gaze.x + rightEye.gaze.x) * 0.5f;
            _eyePos.y = (leftEye.gaze.y + rightEye.gaze.y) * 0.5f;
            if (data.id == 0) {
                leftEye.AddGaze(x, y);
                if (OnEyeGaze != null)
                    OnEyeGaze(this);
            } else if (data.id == 1) {
                rightEye.AddGaze(x, y);
                if (OnEyeGaze != null)
                    OnEyeGaze(this);
            }
        } else if (m_status == EStatus.Calibration) {//gaze calibration stage
            float t = GetPupilTimestamp();
            var ref0 = new Dictionary<string, object>() { { "norm_pos", new float[] { _calibPoints[_currCalibPoint].x, _calibPoints[_currCalibPoint].y } }, { "timestamp", t }, { "id", 0 } };
            var ref1 = new Dictionary<string, object>() { { "norm_pos", new float[] { _calibPoints[_currCalibPoint].x, _calibPoints[_currCalibPoint].y } }, { "timestamp", t }, { "id", 1 } };

            _CalibData(_calibPoints[_currCalibPoint].x, _calibPoints[_currCalibPoint].y);

            _calibrationData.Add(ref0);
            _calibrationData.Add(ref1);
            _currCalibSamples++;
            Thread.Sleep(1000 / 60);

            if (_currCalibSamples >= _calibSamples) {
                _currCalibSamples = 0;
                _currCalibPoint++;

                string pointsData = "[";
                int index = 0;
                foreach (var v in _calibrationData) {
                    pointsData += JsonUtility.ToJson(v);
                    ++index;
                    if (index != _calibrationData.Count) {
                        pointsData += ",";
                    }
                }
                pointsData += "]";
                _sendRequestMessage(new Dictionary<string, object> { { "subject", "calibration.add_ref_data" }, { "ref_data", _CalibrationPoints } });
                _calibrationData.Clear();
                if (_currCalibPoint >= _calibPoints.Length) {

                    StopCalibration();
                }
            }
        }
    }
    private UnityEngine.Transform locationCenter;
    private UnityEngine.Transform locationLeft;
    private UnityEngine.Transform locationRight;
    public delegate void RepaintAction();//InspectorGUI repaint
    public event RepaintAction WantRepaint;
    void OnGUI()//GUI with eye pos, capture rate, time left, VP Number entry field -> only seen by experimenter, not in VR
    {
        string str = "Time Left: " + Timeleft/60 + "min.";
        str += "\nLeft Eye:" + LeftEyePos.ToString();
        str += "\nRight Eye:" + RightEyePos.ToString();
        str += "\nValidation: " + LastValAvg.ToString();
        GUI.TextArea(new Rect(0, 0, 200, 70), str);
        VPNumIn = GUI.TextField(new Rect(0, 70, 200, 20), VPNumIn, 25);
        if (GUI.Button(new Rect(0, 90, 200, 20), "Set VP Number"))
        {
            VPNum = VPNumIn;
            print(VPNum);
        }
    }
    public void RepaintGUI()
    {
        if (WantRepaint != null)
            WantRepaint();
    }
    void Update()
    {
        if (!trainingStarted)
        {
            if (Input.GetKeyDown(KeyCode.T))//start VR training
            {
                if (VPNum.Length == VPNumLen)//Check if entered VP Number is in right range
                {
                    HeadsetCameraRig.position = StartPos;
                    trainingStarted = true;
                    //XX: Comment in if you want to record through Pupil Capture----------------------------------
                    //Record with Pupil Labes -> Higher framerate but takes a lot of space so not used right now
                    //if (!Pupilrecording)
                    //{
                    //    StartPupilServiceRecording(TrackingPath +"PupilRecording");//save recording in the Trackin folder
                    //    Pupilrecording = true;
                    //}-------------------------------------------------------------------------------------------
                    rec.VPNum = VPNum;
                    //start updateInterval loop -> start recording
                    InvokeRepeating("UpdateInterval", updateInterval, updateInterval);
                    //start updateInterval loop in recorder Script -> start recording
                    rec.StartRec();
                }
                else
                {
                    VPNumIn = "Enter"+ VPNumLen.ToString() +"digit VP Number!";//XX: Change to different message if different requirements to VP Number
                }
            }
        }
        else
        {
            if (Input.GetKeyDown(KeyCode.P))//Pause the session and unpause it again (only if training already started)
            {
                if (paused)
                {
                    paused = false;
                    rec.StartRec();
                }
                else
                {
                    rec.StopRec();
                    paused = true;
                }
            }
        }
        CenterX = (leftEye.gaze.x + rightEye.gaze.x) * 0.5f;//add up normalized gaze positions and divide by 2 (-> cyclopian eye gaze normalized)
        CenterY = (leftEye.gaze.y + rightEye.gaze.y) * 0.5f;
        //XX: Comment in if you want to record through Pupil Capture------------------------------------------------------------------
        //if (Input.GetKeyDown(KeyCode.R))//Start and stop pupil data recording 
        //{
        //    if (!Pupilrecording)
        //    {
        //        StartPupilServiceRecording(TrackingPath +"PupilRecording");//save recording in the Tracking folder
        //        Pupilrecording = true;
        //    }
        //    else
        //    {
        //        StopPupilServiceRecording();
        //        Pupilrecording = false;
        //    }
        //}
        if (valStarted) { if (VPNum.Length == 4) { validation3D(); } }//check that VP Number is given such that validation value can be saved.
        if (val2Started) { if (VPNum.Length == 4) { validation2D(); } }
        //transform position of EyeBox in space to point on gaze with distance RayDistance
        EyeBox.transform.localPosition = new Vector3((CenterX - 0.5f) * RayDistance, (CenterY - 0.5f) * RayDistance, RayDistance);
        //save data in a file----------------------------------------------------------------------------------------------------
        if (Input.GetKeyDown(KeyCode.Q))
        {
            StopPupilServiceRecording();
            //gaze data (2D coordinates)
            using (StreamWriter EyeGaze = new StreamWriter(TrackingPath+@"EyesOnScreen\EyesOnScreen_VP"+VPNum +".txt"))
            {
                foreach (var value in Gazes)
                {
                    EyeGaze.WriteLine(value);
                }
            }
            //EyeBoxPos (3D Vector)
            using (StreamWriter BoxPos = new StreamWriter(TrackingPath + @"EyeBoxPos\EyeBoxPos_VP" + VPNum + ".txt"))
            {
                foreach (var value in Boxposs)
                {
                    BoxPos.WriteLine(value);
                }
            }
        }
        if (rec.isRec)//Count down time left
        {
            Timeleft -= Time.deltaTime;
        }
    }
    void UpdateInterval()//Save data x times per second in lists
    {
        Vector3 point = EyeBox.transform.position;
        Vector2 ScreenPoint = new Vector2(CenterX, CenterY);
        if (cam.cullingMask == -1 && trainingStarted &&!paused)
        {
            if (EyesOpen)
            {
                Boxposs.Add(point.ToString("F6"));
                Gazes.Add(ScreenPoint.ToString("F6"));
            }
            else
            {
                point = new Vector3(0.000000f, 0.000000f, 0.000000f);
                Boxposs.Add(point.ToString("F6"));
                Gazes.Add("(0.000000, 0.000000)");
            }
        }
    }
}