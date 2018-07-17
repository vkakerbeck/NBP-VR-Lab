//Script for recording information about player behavior
//Written by Viviane Kakerbeck
//To adapt to your own project search this document for "XX" and set all variables specified
//at the found locations to your own project variables.

//import dependencies
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class recorder : MonoBehaviour
{
    //XX: Variables to set:------------------------------------------------------------------------------------------------
    float updateInterval = 0.033f;//Speed with which recordings are made -> 30 recordings per second
    float SessionLength = 1800;//Length of session in seconds
    string TrackingPath = "D:/v.kakerbeck/Tracking/";//Path to the folder where you want to save your tracking results
    //Other variables:-----------------------------------------------------------------------------------------------------
    List<string> nums = new List<string>();//List with player positions
    public string VPNum;
    //int newNum;//XX: Uncomment if you want automatic VP Number counting (no manual input -> less risk of overwriting data)
    public bool isRec = false;//Recording positions?
    bool TrainingStarted = false;//Training started? -> starts recording
    string tempPos;//Current position
    float timestamp;//times stamp for cross synchronization of recordings
    //Game objects -> set in Start()
    GameObject Camera;
    GameObject eye;
    Camera cam;
    PupilGazeTracker tracker;
    void Start()
    {
        //XX: Change to object names in your scene
        Camera = GameObject.Find("EyeCube");//Reference Object
        eye = GameObject.Find("Camera (eye)");//Camera Object of VR player
        cam = eye.GetComponent<Camera>();//Camera of VR player
        tracker = transform.GetComponentInParent<PupilGazeTracker>();//Conenction to PupilGazeTracker
        //XX: Uncomment if you want automatic VP Number counting (no manual input -> less risk of overwriting data)---------
        //if (VPNum.Length == 0)//If VPNum is not specified, analyze last subject recorded
        //{
        //    System.IO.StreamReader VPN = new System.IO.StreamReader(@"D:\v.kakerbeck\Tracking\currentVP.txt");
        //    VPNum = VPN.ReadLine();
        //    VPN.Close();
        //}
        //newNum = System.Convert.ToInt16(VPNum) + 1;
        //VPNum = newNum.ToString();
        //if (newNum < 10) { VPNum = "0" + newNum.ToString(); }
        //-----------------------------------------------------------------------------------------------------------------
    }
    public void StartRec()//Start recording
    {
        InvokeRepeating("UpdateInterval", updateInterval, updateInterval);
        TrainingStarted = true;
    }
    public void StopRec()//Stop recording
    {
        TrainingStarted = false;
    }
    void UpdateInterval()//Record
    {
        if(cam.cullingMask == -1 && TrainingStarted )
        {
            isRec = true;
        }
        else { isRec = false;}
        if (isRec)
        {
            timestamp = SessionLength-tracker.Timeleft;//camculate time stamp for each frame = seconds since training was started
            tempPos = (transform.position.x.ToString("F2") + ", " + transform.position.y.ToString("F2") + ", " + transform.position.z.ToString("F2") + ", " + Camera.transform.rotation.eulerAngles.x.ToString("F2") + ", "+ Camera.transform.rotation.eulerAngles.y.ToString("F2") + ", " + Camera.transform.rotation.eulerAngles.z.ToString("F2") + ", " + timestamp.ToString("F2")+", "+tracker.GetPupilTimestamp().ToString());
            nums.Add(tempPos);//add position and rotation to list
        }
        if (Input.GetKeyDown(KeyCode.Q))//Save recordings
        {
            isRec = false;
            using (StreamWriter writer = new StreamWriter(TrackingPath+@"Position\positions_VP" + VPNum + ".txt"))
            {
                foreach (var value in nums)
                {
                    writer.WriteLine(value);
                }
            }
            //XX: Uncomment if you want automatic VP Number counting-----------------------------------------------------------------
            //using (StreamWriter writer = new StreamWriter(TrackingPath+@"currentVP.txt"))
            //{
            //    writer.WriteLine(VPNum);
            //}
            //UnityEditor.EditorApplication.isPlaying = false;//Use for ending session inside of Unity
            Application.Quit(); //Use to quit when using a build application of your project
        }
    }
}