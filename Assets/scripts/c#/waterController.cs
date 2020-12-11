using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class waterController : MonoBehaviour
{

    public GameObject Water1;
    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void AddForceToWater(Vector3 position, float amount){
        Water1.GetComponent<water>().AddForceToWater(position, amount);
    }
}
