using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class playerLegs : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void AddForce(Vector3 force){
        this.GetComponent<Rigidbody>().AddForce(force, ForceMode.Force);
    }
    
    public void AddForceAtPosition(Vector3 force, Vector3 position){
        this.GetComponent<Rigidbody>().AddForceAtPosition(force, position, ForceMode.Force);
    }

}
