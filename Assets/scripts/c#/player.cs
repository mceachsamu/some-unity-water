using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class player : MonoBehaviour
{

    public float rotateRate = 100.0f;

    private float forceDivisions = 5.0f;

    public float force = 1.0f;

    public GameObject Legs;

    public GameObject water;
    public GameObject waterController;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {

        this.transform.position = Legs.transform.position;
        if (Input.GetKey(KeyCode.RightArrow)){
            this.transform.RotateAround(this.transform.position, Vector3.up, rotateRate);
        }
        if (Input.GetKey(KeyCode.LeftArrow)){
            this.transform.RotateAround(this.transform.position, Vector3.up, -rotateRate);
        }
        if (Input.GetKey("w")){
            Legs.GetComponent<playerLegs>().AddForce(this.transform.forward * 5.0f);
        }
        if (Input.GetKey("s")){
            Legs.GetComponent<playerLegs>().AddForce(this.transform.forward * -5.0f);
        }
        if (Input.GetKey("a")){
            Legs.GetComponent<playerLegs>().AddForce(this.transform.right * -5.0f);
        }
        if (Input.GetKey("d")){
            Legs.GetComponent<playerLegs>().AddForce(this.transform.right * 5.0f);
        }

        float height = water.GetComponent<water>().getHeightAtPosition(this.transform.position);
        if (this.transform.position.y < height){
            Legs.GetComponent<playerLegs>().AddForce(Vector3.up*20.0f);
        }
        
        water w = water.GetComponent<water>();
        Vector3 pos = w.transform.position;
        pos.x = this.transform.position.x;
        pos.z = this.transform.position.z;
        water.transform.position = pos;

        Vector3 BackwardsVelocity = (GetVelocity())*-0.5f;

        //dont care about y velocity
        BackwardsVelocity.y = this.transform.position.y;
        BackwardsVelocity = BackwardsVelocity / forceDivisions;
        if (this.transform.position.y-0.5f < height){
            //touching water, so add force
            for(float i = 0.0f; i < forceDivisions; i++){
                Vector3 posC = this.transform.position + BackwardsVelocity * i;
                float forceC = force / (i+1.0f);
                water.GetComponent<water>().AddForceToWater(posC, forceC);
            }

                // water.GetComponent<water>().AddForceToWater(this.transform.position + BackwardsVelocity, 10.0f);
        }
        Debug.DrawLine(this.transform.position, this.transform.position - GetVelocity(), Color.red);
}
    public Vector3 GetVelocity(){
        return Legs.GetComponent<Rigidbody>().velocity;
    }
}
