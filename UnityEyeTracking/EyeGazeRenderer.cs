// Pupil Gaze Renderer
// Written by MHD Yamen Saraiji. Modified by Viviane Kakerbeck.
// original code by MHD Yamen Saraiji: https://github.com/mrayy
//To adapt to your own project search this document for "XX" and set all variables specified
//at the found locations to your own project variables.

//Import dependencies
using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine.UI;

public class EyeGazeRenderer : MonoBehaviour
{
	public RectTransform gaze;
    public Image _image;
    public PupilGazeTracker.GazeSource Gaze;
    void Start() {	
		if (gaze == null)
			gaze = this.GetComponent<RectTransform> ();
        _image = GetComponent<Image>();
        _image.enabled = false;
    }
	void Update() {
        if (Input.GetKeyDown(KeyCode.C)|| Input.GetKeyDown(KeyCode.O))//calibration
            _image.enabled = true;//show marker
        if (Input.GetKeyDown(KeyCode.V))//validation
            _image.enabled = true;
        if (Input.GetKeyDown(KeyCode.D))//validation in 3D space
            _image.enabled = true;
        if (Input.GetKeyDown(KeyCode.F))//fast validation with one point
            _image.enabled = true;
        if (gaze == null)
                return;
            Canvas c = gaze.GetComponentInParent<Canvas>();
            Vector2 g = PupilGazeTracker.Instance.GetEyeGaze(Gaze);
            gaze.localPosition = new Vector3((g.x - 0.5f) * c.pixelRect.width, (g.y - 0.5f) * c.pixelRect.height, 0);
        if (Input.GetKeyDown(KeyCode.S))
        {
            _image.enabled = false;//hide markers
        }
	}
}