<<<<<<< HEAD
﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

public class DrawAllPaths : MonoBehaviour {

    string line;
    string house;
    float distance;
    bool alreadyDone = false;
    public bool randomizePositions;
    public bool randomizeGaze;
    Vector4 position;
    GameObject EyeBox;
    public float RayDistance = 160;
    public float NumAnalyze;
    public bool visualize;
    string VPNum;
    string heatPath;
    //string savePath = @"C:\Users\vivia\Dropbox\Project Seahaven\Tracking\";
    string savePath = @"D:\v.kakerbeck\Tracking\";
    void Start()
    {
        
        EyeBox = GameObject.Find("EyeBox");
        var info = new DirectoryInfo(savePath + @"Position\");
        var fileInfo = info.GetFiles("*.txt");

        for (int VP = 0; VP < NumAnalyze; VP++)
        {
            string filename = fileInfo[VP].Name;
            VPNum = filename.Substring(filename.Length - 8, 4);
            if (File.Exists(savePath + @"ViewedHouses\ViewedHouses_VP" + VPNum + ".txt"))
            {
                print("File for VP " + VPNum + " already exists.");
            }
            else
            {
                print("File for VP " + VPNum + " generated");
                List<Vector3> HitList = new List<Vector3>();
                List<Vector3> positionL = new List<Vector3>();
                List<Vector3> EyePosList = new List<Vector3>();
                List<float> Timestamps = new List<float>();
                List<float> rotations = new List<float>();
                List<string> Gazes = new List<string>(); //vector with (EyeOnScreenX,EyeOnScreenY,DistanceOfHit)
                List<string> houses = new List<string>();
                if (randomizePositions) { randomizeGaze = false; }

                heatPath = savePath+ @"Heatmap3D\3DHeatmap_VP" + VPNum + ".txt";
                //read in position file -> to calculate hit points
                System.IO.StreamReader positions = new System.IO.StreamReader(savePath + @"Position\positions_VP" + VPNum + ".txt");
                while ((line = positions.ReadLine()) != null)
                {
                    Vector4 position = StringToVector4(line);
                    positionL.Add(new Vector3(position[0], position[1], position[2]));
                    rotations.Add(position[3]);
                    Timestamps.Add(getTimeStamp(line));
                }
                positions.Close();
                //read in EyeBoxPos file -> to calculate hit points
                if (!randomizeGaze)
                {
                    System.IO.StreamReader EyeBoxPos = new System.IO.StreamReader(savePath + @"EyeBoxPos\EyeBoxPos_VP" + VPNum + ".txt");
                    while ((line = EyeBoxPos.ReadLine()) != null)
                    {
                        EyePosList.Add(StringToVector3(line));
                    }
                    EyeBoxPos.Close();
                    //read in EyesOnScreen file -> to complete with distance info for 3D Heatmap

                    System.IO.StreamReader EyesOnScreen = new System.IO.StreamReader(savePath + @"EyesOnScreen\EyesOnScreen_VP" + VPNum + ".txt");
                    while ((line = EyesOnScreen.ReadLine()) != null)
                    {
                        Gazes.Add(line);
                    }
                    EyesOnScreen.Close();
                }
                else//create random eyeGazes while keeping the players position
                {
                    for (int n = 0; n < positionL.Count; n++)
                    {
                        Vector2 RandEyePos = new Vector2(Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f));//random 2D gaze pos
                        Gazes.Add(RandEyePos.ToString("f6"));
                        transform.position = positionL[n];
                        transform.localEulerAngles = new Vector3(0, rotations[n], 0);
                        EyeBox.transform.localPosition = (new Vector3((RandEyePos[0] - 0.5f) * RayDistance, (RandEyePos[1] - 0.5f) * RayDistance, RayDistance));//transform ito 3D vector
                        EyePosList.Add(EyeBox.transform.position);
                        heatPath = savePath + @"Heatmap3D\3DHeatmapRandomGaze_VP" + VPNum + ".txt";
                    }
                }

                //--------------------------------suffles position list-----------------------------------------------
                if (randomizePositions)
                {
                    heatPath = savePath + @"Heatmap3D\3DHeatmapRandomPos_VP" + VPNum + ".txt";
                    for (int x = 0; x < positionL.Count; x++)//from http://answers.unity3d.com/questions/486626/how-can-i-shuffle-alist.html
                    {
                        Vector4 temp = positionL[x];
                        int randomIndex = Random.Range(x, positionL.Count);
                        positionL[x] = positionL[randomIndex];
                        positionL[randomIndex] = temp;
                    }
                }
                //---------------shoot ray and calculate hit points, distances + houses hit---------------------------
                int i = 0;
                foreach (Vector3 Eyep in EyePosList) //to use every eye pos
                {
                    if (i < positionL.Count)
                    {
                        if (Eyep[0] != 0)
                        {
                            RaycastHit hit;
                            Ray Eye = new Ray(positionL[i], Eyep - positionL[i]);//Gaze ray
                            if (Physics.Raycast(Eye, out hit))
                            {
                                if (hit.collider.tag == "House")
                                {
                                    house = hit.collider.name;
                                    distance = hit.distance;
                                    string houseout = house + "," + distance + "," + Timestamps[i];
                                    houses.Add(houseout);
                                }
                                else
                                {
                                    distance = hit.distance;
                                    //print(distance);
                                    string houseout = "NH" + "," + distance + "," + Timestamps[i];
                                    houses.Add(houseout);
                                }
                                Gazes[i] = Gazes[i].Substring(0, Gazes[i].Length - 1) + ", " + hit.distance.ToString("F6") + ")";
                                if (visualize)
                                {
                                    Color color = new Color(hit.distance / 20, 1, 1, 100);//new Color(hit.distance/10, 1, hit.distance/30, 1)
                                    GameObject sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                                    sphere.transform.position = hit.point;
                                    sphere.transform.localScale = new Vector3(0.5f, 0.5f, 0.5f);
                                    Collider c = sphere.GetComponent<Collider>();
                                    c.enabled = false;
                                    Renderer rend2 = sphere.GetComponent<Renderer>();
                                    rend2.material.color = color;
                                }
                                }
                                else
                            {
                                Gazes[i] = Gazes[i].Substring(0, Gazes[i].Length - 1) + ", 200)";
                                string houseout = "NH" + "," + "200" + "," + Timestamps[i];
                                houses.Add(houseout);
                            }
                        }
                        else
                        {
                            string houseout = "NH" + "," + "0" + "," + Timestamps[i];
                            houses.Add(houseout);
                            Gazes[i] = Gazes[i].Substring(0, Gazes[i].Length - 1) + ", 0)";
                        }
                        i = i + 1;
                    }
                }
                if (!randomizePositions && !randomizeGaze)//nothing random -> save houses looked at
                {
                    using (StreamWriter writer = new StreamWriter(savePath + @"ViewedHouses\ViewedHouses_VP" + VPNum + ".txt"))//save viewedHouses
                    {
                        foreach (var value in houses)
                        {
                            writer.WriteLine(value);
                        }
                    }
                }
                using (StreamWriter writer = new StreamWriter(heatPath))//save 2D eye pos + distance of object looked at
                {
                    foreach (var gaze in Gazes)
                    {
                        writer.WriteLine(gaze);
                    }
                }
            }
        }
    }
    public static Vector4 StringToVector4(string sVector)
    {
        // Remove the parentheses
        if (sVector.StartsWith("(") && sVector.EndsWith(")"))
        {
            sVector = sVector.Substring(1, sVector.Length - 2);
        }

        // split the items
        string[] sArray = sVector.Split(',');

        // store as a Vector3
        Vector4 result = new Vector4(
            float.Parse(sArray[0]),
            float.Parse(sArray[1]),
            float.Parse(sArray[2]),
            float.Parse(sArray[4]));
        float ts = float.Parse(sArray[6]);
        return result;
    }
    public static Vector3 StringToVector3(string sVector)
    {
        // Remove the parentheses
        if (sVector.StartsWith("(") && sVector.EndsWith(")"))
        {
            sVector = sVector.Substring(1, sVector.Length - 2);
        }

        // split the items
        string[] sArray = sVector.Split(',');

        // store as a Vector3
        Vector3 result = new Vector3(
            float.Parse(sArray[0]),
            float.Parse(sArray[1]),
            float.Parse(sArray[2]));

        return result;
    }
    public static Vector2 StringToVector2(string sVector)
    {
        // Remove the parentheses
        if (sVector.StartsWith("(") && sVector.EndsWith(")"))
        {
            sVector = sVector.Substring(1, sVector.Length - 2);
        }

        // split the items
        string[] sArray = sVector.Split(',');

        // store as a Vector3
        Vector2 result = new Vector2(
            float.Parse(sArray[0]),
            float.Parse(sArray[1]));

        return result;
    }
    public static float getTimeStamp(string sVector)
    {
        if (sVector.StartsWith("(") && sVector.EndsWith(")"))
        {
            sVector = sVector.Substring(1, sVector.Length - 2);
        }
        string[] sArray = sVector.Split(',');
        float ts = float.Parse(sArray[6]);
        return ts;
    }

}
=======
﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

public class DrawAllPaths : MonoBehaviour {

    string line;
    string house;
    float distance;
    bool alreadyDone = false;
    public bool randomizePositions;
    public bool randomizeGaze;
    Vector4 position;
    GameObject EyeBox;
    public float RayDistance = 160;
    public float NumAnalyze;
    public bool visualize;
    string VPNum;
    string heatPath;
    //string savePath = @"C:\Users\vivia\Dropbox\Project Seahaven\Tracking\";
    string savePath = @"D:\v.kakerbeck\Tracking\";
    void Start()
    {
        
        EyeBox = GameObject.Find("EyeBox");
        var info = new DirectoryInfo(savePath + @"Position\");
        var fileInfo = info.GetFiles("*.txt");

        for (int VP = 0; VP < NumAnalyze; VP++)
        {
            string filename = fileInfo[VP].Name;
            VPNum = filename.Substring(filename.Length - 8, 4);
            if (File.Exists(savePath + @"ViewedHouses\ViewedHouses_VP" + VPNum + ".txt"))
            {
                print("File for VP " + VPNum + " already exists.");
            }
            else
            {
                print("File for VP " + VPNum + " generated");
                List<Vector3> HitList = new List<Vector3>();
                List<Vector3> positionL = new List<Vector3>();
                List<Vector3> EyePosList = new List<Vector3>();
                List<float> Timestamps = new List<float>();
                List<float> rotations = new List<float>();
                List<string> Gazes = new List<string>(); //vector with (EyeOnScreenX,EyeOnScreenY,DistanceOfHit)
                List<string> houses = new List<string>();
                if (randomizePositions) { randomizeGaze = false; }

                heatPath = savePath+ @"Heatmap3D\3DHeatmap_VP" + VPNum + ".txt";
                //read in position file -> to calculate hit points
                System.IO.StreamReader positions = new System.IO.StreamReader(savePath + @"Position\positions_VP" + VPNum + ".txt");
                while ((line = positions.ReadLine()) != null)
                {
                    Vector4 position = StringToVector4(line);
                    positionL.Add(new Vector3(position[0], position[1], position[2]));
                    rotations.Add(position[3]);
                    Timestamps.Add(getTimeStamp(line));
                }
                positions.Close();
                //read in EyeBoxPos file -> to calculate hit points
                if (!randomizeGaze)
                {
                    System.IO.StreamReader EyeBoxPos = new System.IO.StreamReader(savePath + @"EyeBoxPos\EyeBoxPos_VP" + VPNum + ".txt");
                    while ((line = EyeBoxPos.ReadLine()) != null)
                    {
                        EyePosList.Add(StringToVector3(line));
                    }
                    EyeBoxPos.Close();
                    //read in EyesOnScreen file -> to complete with distance info for 3D Heatmap

                    System.IO.StreamReader EyesOnScreen = new System.IO.StreamReader(savePath + @"EyesOnScreen\EyesOnScreen_VP" + VPNum + ".txt");
                    while ((line = EyesOnScreen.ReadLine()) != null)
                    {
                        Gazes.Add(line);
                    }
                    EyesOnScreen.Close();
                }
                else//create random eyeGazes while keeping the players position
                {
                    for (int n = 0; n < positionL.Count; n++)
                    {
                        Vector2 RandEyePos = new Vector2(Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f));//random 2D gaze pos
                        Gazes.Add(RandEyePos.ToString("f6"));
                        transform.position = positionL[n];
                        transform.localEulerAngles = new Vector3(0, rotations[n], 0);
                        EyeBox.transform.localPosition = (new Vector3((RandEyePos[0] - 0.5f) * RayDistance, (RandEyePos[1] - 0.5f) * RayDistance, RayDistance));//transform ito 3D vector
                        EyePosList.Add(EyeBox.transform.position);
                        heatPath = savePath + @"Heatmap3D\3DHeatmapRandomGaze_VP" + VPNum + ".txt";
                    }
                }

                //--------------------------------suffles position list-----------------------------------------------
                if (randomizePositions)
                {
                    heatPath = savePath + @"Heatmap3D\3DHeatmapRandomPos_VP" + VPNum + ".txt";
                    for (int x = 0; x < positionL.Count; x++)//from http://answers.unity3d.com/questions/486626/how-can-i-shuffle-alist.html
                    {
                        Vector4 temp = positionL[x];
                        int randomIndex = Random.Range(x, positionL.Count);
                        positionL[x] = positionL[randomIndex];
                        positionL[randomIndex] = temp;
                    }
                }
                //---------------shoot ray and calculate hit points, distances + houses hit---------------------------
                int i = 0;
                foreach (Vector3 Eyep in EyePosList) //to use every eye pos
                {
                    if (i < positionL.Count)
                    {
                        if (Eyep[0] != 0)
                        {
                            RaycastHit hit;
                            Ray Eye = new Ray(positionL[i], Eyep - positionL[i]);//Gaze ray
                            if (Physics.Raycast(Eye, out hit))
                            {
                                if (hit.collider.tag == "House")
                                {
                                    house = hit.collider.name;
                                    distance = hit.distance;
                                    string houseout = house + "," + distance + "," + Timestamps[i];
                                    houses.Add(houseout);
                                }
                                else
                                {
                                    distance = hit.distance;
                                    //print(distance);
                                    string houseout = "NH" + "," + distance + "," + Timestamps[i];
                                    houses.Add(houseout);
                                }
                                Gazes[i] = Gazes[i].Substring(0, Gazes[i].Length - 1) + ", " + hit.distance.ToString("F6") + ")";
                                if (visualize)
                                {
                                    Color color = new Color(hit.distance / 20, 1, 1, 100);//new Color(hit.distance/10, 1, hit.distance/30, 1)
                                    GameObject sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                                    sphere.transform.position = hit.point;
                                    sphere.transform.localScale = new Vector3(0.5f, 0.5f, 0.5f);
                                    Collider c = sphere.GetComponent<Collider>();
                                    c.enabled = false;
                                    Renderer rend2 = sphere.GetComponent<Renderer>();
                                    rend2.material.color = color;
                                }
                                }
                                else
                            {
                                Gazes[i] = Gazes[i].Substring(0, Gazes[i].Length - 1) + ", 200)";
                                string houseout = "NH" + "," + "200" + "," + Timestamps[i];
                                houses.Add(houseout);
                            }
                        }
                        else
                        {
                            string houseout = "NH" + "," + "0" + "," + Timestamps[i];
                            houses.Add(houseout);
                            Gazes[i] = Gazes[i].Substring(0, Gazes[i].Length - 1) + ", 0)";
                        }
                        i = i + 1;
                    }
                }
                if (!randomizePositions && !randomizeGaze)//nothing random -> save houses looked at
                {
                    using (StreamWriter writer = new StreamWriter(savePath + @"ViewedHouses\ViewedHouses_VP" + VPNum + ".txt"))//save viewedHouses
                    {
                        foreach (var value in houses)
                        {
                            writer.WriteLine(value);
                        }
                    }
                }
                using (StreamWriter writer = new StreamWriter(heatPath))//save 2D eye pos + distance of object looked at
                {
                    foreach (var gaze in Gazes)
                    {
                        writer.WriteLine(gaze);
                    }
                }
            }
        }
    }
    public static Vector4 StringToVector4(string sVector)
    {
        // Remove the parentheses
        if (sVector.StartsWith("(") && sVector.EndsWith(")"))
        {
            sVector = sVector.Substring(1, sVector.Length - 2);
        }

        // split the items
        string[] sArray = sVector.Split(',');

        // store as a Vector3
        Vector4 result = new Vector4(
            float.Parse(sArray[0]),
            float.Parse(sArray[1]),
            float.Parse(sArray[2]),
            float.Parse(sArray[4]));
        float ts = float.Parse(sArray[6]);
        return result;
    }
    public static Vector3 StringToVector3(string sVector)
    {
        // Remove the parentheses
        if (sVector.StartsWith("(") && sVector.EndsWith(")"))
        {
            sVector = sVector.Substring(1, sVector.Length - 2);
        }

        // split the items
        string[] sArray = sVector.Split(',');

        // store as a Vector3
        Vector3 result = new Vector3(
            float.Parse(sArray[0]),
            float.Parse(sArray[1]),
            float.Parse(sArray[2]));

        return result;
    }
    public static Vector2 StringToVector2(string sVector)
    {
        // Remove the parentheses
        if (sVector.StartsWith("(") && sVector.EndsWith(")"))
        {
            sVector = sVector.Substring(1, sVector.Length - 2);
        }

        // split the items
        string[] sArray = sVector.Split(',');

        // store as a Vector3
        Vector2 result = new Vector2(
            float.Parse(sArray[0]),
            float.Parse(sArray[1]));

        return result;
    }
    public static float getTimeStamp(string sVector)
    {
        if (sVector.StartsWith("(") && sVector.EndsWith(")"))
        {
            sVector = sVector.Substring(1, sVector.Length - 2);
        }
        string[] sArray = sVector.Split(',');
        float ts = float.Parse(sArray[6]);
        return ts;
    }

}
>>>>>>> 2e7f82c96b15ca02448d9283b2ccd0854bb5208b
