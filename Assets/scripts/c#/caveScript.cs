using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class caveScript : MonoBehaviour
{

    private float count;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        count++;
         this.GetComponent<Renderer>().material.SetFloat("_Count", count);
    }
}
