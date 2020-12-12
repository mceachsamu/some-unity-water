using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class player : MonoBehaviour
{

    public float rotateRate = 100.0f;

    private float forceDivisions = 10.0f;

    public float force = 1.0f;

    public GameObject Legs;

    public GameObject water;
    public GameObject waterController;

    public float buoyancey = 100.0f;

    private float xRot = 0.0f;
    private float zRot = 0.0f;
    private float yRot = 0.0f;

    private Quaternion startRot;

    // Start is called before the first frame update
    void Start()
    {
        startRot = this.transform.rotation;
    }

    // Update is called once per frame
    void Update()
    {
        print(water.GetComponent<water>().getHeightAtPosition(water.transform.position));
        this.transform.position = Legs.transform.position;
        if (Input.GetKey(KeyCode.RightArrow)){
        }
        if (Input.GetKey(KeyCode.LeftArrow)){
            //this.transform.RotateAround(this.transform.position, Vector3.up, -rotateRate);
        }
        if (Input.GetKey("w")){
            Legs.GetComponent<playerLegs>().AddForce(this.transform.up * force);
        }
        if (Input.GetKey("s")){
            Legs.GetComponent<playerLegs>().AddForce(this.transform.up * -force);
        }

        if (Input.GetKey("a")){

            xRot -= Time.deltaTime * 100.0f;
            zRot += Time.deltaTime * 30.0f;
            yRot -= Time.deltaTime * 50.0f;
            Legs.GetComponent<playerLegs>().AddForce(this.transform.right * force * 0.3f);
        }
        if (Input.GetKey("d")){
            xRot += Time.deltaTime * 100.0f;
            zRot += Time.deltaTime * 30.0f;
            yRot += Time.deltaTime * 50.0f;
            Legs.GetComponent<playerLegs>().AddForce(this.transform.right * -force * 0.3f);
        }

        xRot -= Mathf.Pow(xRot/20.0f,3.0f);
        zRot -= Mathf.Pow(zRot/15.0f, 3.0f);

        this.transform.rotation = startRot;
        this.transform.RotateAround(this.transform.position, new Vector3(0.0f,0.0f,1.0f), xRot);
        this.transform.RotateAround(this.transform.position, new Vector3(1.0f,0.0f,0.0f), zRot);
        this.transform.RotateAround(this.transform.position, new Vector3(0.0f,1.0f,0.0f), yRot);

        float height = water.GetComponent<water>().getHeightAtPosition(this.transform.position);
        if (this.transform.position.y-1.3f < height){
            Legs.GetComponent<playerLegs>().AddForce(Vector3.up*buoyancey);
        }

        water w = water.GetComponent<water>();
        Vector3 pos = w.transform.position;
        pos.x = this.transform.position.x;
        pos.z = this.transform.position.z;
        water.transform.position = pos;

        Vector3 BackwardsVelocity = (GetVelocity())*-1.0f;

        //dont care about y velocity
        BackwardsVelocity.y = this.transform.position.y;
        BackwardsVelocity = BackwardsVelocity / forceDivisions;
        if (this.transform.position.y-1.5f < height){
            //touching water, so add force
            for(float i = 0.0f; i < forceDivisions; i++){
                Vector3 posC = this.transform.position + BackwardsVelocity * i;
                float forceC = (force / Mathf.Pow(i+1.0f,5.0f)) * GetVelocity().magnitude / 10.0f;
                water.GetComponent<water>().AddForceToWater(posC, forceC);
            }
        }
}
    public Vector3 GetVelocity(){
        return Legs.GetComponent<Rigidbody>().velocity;
    }
}
