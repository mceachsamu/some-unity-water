using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class lightController : MonoBehaviour
{

    public GameObject player;

    private float[] sequence = new float[]{0.00004f,0.00007f,0.00003f,0.00005f,0.00006f,-0.00003f,0.00004f};
    private int counter;
    private int counter2;
    private float origin;
    // Start is called before the first frame update
    void Start()
    {
        origin = this.transform.position.y;
    }

    // Update is called once per frame
    void Update()
    {
        counter2++;
        Vector3 pos = player.transform.position;
        pos.y = sequence[counter] + origin;
        if (counter2 % 10 == 0){
            counter++;
        }
        if (counter >= sequence.Length){
            pos.y = origin;
            counter = 0;
        }
        this.transform.position = pos;
    }
}
