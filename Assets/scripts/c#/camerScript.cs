using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class camerScript : MonoBehaviour
{

    public GameObject Player;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 pos = Player.transform.position;
        pos -= Player.transform.forward * 15.0f;
        pos.y += 2.0f;
        this.transform.position = pos;
        this.transform.forward = ( Player.transform.position - this.transform.position);
    }
}
