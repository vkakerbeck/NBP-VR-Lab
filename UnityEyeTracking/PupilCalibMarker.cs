// Pupil Calib Marker
// Written by MHD Yamen Saraiji. Modified by Viviane Kakerbeck.
// original code by MHD Yamen Saraiji: https://github.com/mrayy
//To adapt to your own project search this document for "XX" and set all variables specified
//at the found locations to your own project variables.

//Import dependencies
using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class PupilCalibMarker : MonoBehaviour {
    //Variables:--------------------------------------------------------------------------
	RectTransform _transform;
	Image _image;
	bool _started=false;
	float x,y;
    GameObject eye;
    Camera cam;
    //bools to check if validation or calibration is running
    bool cal = false;
    bool val2 = false;
    bool val3 = false;
	void Start () {
		_transform = GetComponent<RectTransform> ();
		_image = GetComponent<Image> ();
		_image.enabled = false;
		PupilGazeTracker.Instance.OnCalibrationStarted += OnCalibrationStarted;
		PupilGazeTracker.Instance.OnCalibrationDone += OnCalibrationDone;
		PupilGazeTracker.Instance.OnCalibData += OnCalibData;
        eye = GameObject.Find("Camera (eye)");//XX:Change to name of camera object in your project
        cam = eye.GetComponent<Camera>();
    }
	void OnCalibrationStarted(PupilGazeTracker m)
	{
		_started = true;
	}
	void OnCalibrationDone(PupilGazeTracker m)
	{
		_started = false;
	}
	void OnCalibData(PupilGazeTracker m,float x,float y)
	{
		this.x = x;
		this.y = y;
	}
	void _SetLocation(float x,float y)//Set location of markers
	{
		Canvas c = _transform.GetComponentInParent<Canvas> ();
		if (c == null)
			return;
		Vector3 pos=new Vector3 ((x-0.5f)*c.pixelRect.width,(y-0.5f)*c.pixelRect.height,0);
		_transform.localPosition = pos;
	}
    void Update () {
        if (Input.GetKeyDown(KeyCode.C))//start callibration
        {
            PupilGazeTracker.Instance.StartCalibration();
            cam.cullingMask = 1 << LayerMask.NameToLayer("UI");
            cal = true;
        }
        //if (Input.GetKeyDown(KeyCode.O))//3-Point Calibration -> does not help (makes calibration worse since it throws away old points)
        //{
        //    PupilGazeTracker.Instance.StartCalibration(new Vector2[] {new Vector2(0.3f,0.5f), new Vector2(0.5f, 0.5f),new Vector2(0.7f,0.5f) },120);
        //    cam.cullingMask = 1 << LayerMask.NameToLayer("UI");
        //    cal = true;
        //}
        if (Input.GetKeyDown(KeyCode.S))//stop validation or callibration
        {
            if (cal) { PupilGazeTracker.Instance.StopCalibration(); cal = false; }
            if (val2)
            {
                if (PupilGazeTracker.Instance.val2Started)
                {
                    PupilGazeTracker.Instance.StopValidation2D(); val2 = false;
                }
            }
            if (val3)
            {
                if (PupilGazeTracker.Instance.valStarted)
                {
                    PupilGazeTracker.Instance.StopValidation3D(); val3 = false;
                }
            }
            cam.cullingMask = -1;
            Image i = transform.GetComponent<Image>();
            i.enabled = false;
            _started = false;
        }
        if (Input.GetKeyDown(KeyCode.V))//start 2D validation 
        {
            
            PupilGazeTracker.Instance.StartValidation2D(new Vector2[] {new Vector2(0.5f, 0.5f),
            new Vector2(0.3f, 0.3f), new Vector2(0.3f, 0.5f), new Vector2(0.3f, 0.7f), new Vector2(0.5f, 0.7f),
            new Vector2(0.7f, 0.7f),new Vector2(0.7f, 0.5f),new Vector2(0.7f, 0.3f),new Vector2(0.5f, 0.3f)});//9 point validation, leaving out the far periphery
            cam.cullingMask = 1 << LayerMask.NameToLayer("UI");
            val2 = true;
            _started = true;
            //17 Points, same as calibration
            //    {new Vector2(0.5f, 0.5f),
            //new Vector2(0.2f, 0.2f), new Vector2(0.2f, 0.5f),
            //new Vector2(0.2f, 0.8f), new Vector2(0.5f, 0.8f), new Vector2(0.8f, 0.8f),
            //new Vector2(0.8f, 0.5f), new Vector2(0.8f, 0.2f), new Vector2(0.5f, 0.2f),
            //new Vector2(0.3f, 0.3f), new Vector2(0.3f, 0.5f), new Vector2(0.3f, 0.7f), new Vector2(0.5f, 0.7f),
            //new Vector2(0.7f, 0.7f),new Vector2(0.7f, 0.5f),new Vector2(0.7f, 0.3f),new Vector2(0.5f, 0.3f)}
        }
        if (Input.GetKeyDown(KeyCode.D))//3D validation
        {
            PupilGazeTracker.Instance.StartValidation3D(new Vector2[] { new Vector2(0.5f, 0.5f),
            new Vector2(0.3f, 0.3f), new Vector2(0.3f, 0.5f), new Vector2(0.3f, 0.7f), new Vector2(0.5f, 0.7f),
            new Vector2(0.7f, 0.7f), new Vector2(0.7f, 0.5f), new Vector2(0.7f, 0.3f), new Vector2(0.5f, 0.3f)});
            cam.cullingMask = 1 << LayerMask.NameToLayer("Default");//9 point validation, leaving out the far periphery
            _started = true;
            val3 = true;
            _image.enabled = false;
        }
        if (Input.GetKeyDown(KeyCode.F))//Fast one point validation
        {
            PupilGazeTracker.Instance.StartValidation2D(new Vector2[] { new Vector2(0.5f, 0.5f) });
            cam.cullingMask = 1 << LayerMask.NameToLayer("UI");
            val2 = true;
            _started = true;
        }
        _image.enabled = _started;
        if(cam.cullingMask == -1) { _started = false; }
		if(_started)
			_SetLocation (x, y);
	}
}