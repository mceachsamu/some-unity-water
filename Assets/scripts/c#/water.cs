using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Reflection;
public class water : MonoBehaviour
{
    //the number of segments the plane is made up from
    public int numSegs = 10;
    //the size of the segments on the plane generated
    public float segSize = 5.0f;

    //how quickly objects fade in water
    [Range(0.0f, 3.0f)]
    public float waterOpaqueness = 1.0f;

    //the main color of the water
    public Color primaryCol = new Color(155.0f/255,0.0f/255.0f,28.0f/255.0f);
    //the number of points defining the phsyical water mesh (complexity of (numFieldPoints ^ 2) * 4)
    public int numFieldPoints = 10;
    //the physical water mesh points, these define the y positions of the water surface
    private point[,] pointField;

    //the resulting texture from the points field
    public Texture2D heightMap;

    //list our constants for our water physics

    //neighbourFriction defines how much neighbouring points influence each other
    [Range(0.0f, 0.3f)]
    public float neighbourFriction = 0.1f;
    //friction defines amount of counter force for each point (higher friction const -> less friction)
    [Range(0.8f, 1.0f)]
    public float friction = 0.9f;
    //drag defines how quickly the acceleration of a point is decreased at each frame (higher drag const -> less drag)
    [Range(0.9f, 1.0f)]
    public float drag = 0.97f;
    //maxHeight defines the height of the water that we allow. at lower values the water surface is more defined. higher less defined but smoother
    [Range(0.1f, 5.0f)]
    public float maxHeight = 1.0f;
    //the mass defines the mass of each point. this effects how much points are effected by forces
    [Range(1.0f, 10.0f)]
    public float mass = 3.0f;
    //deceleration defines the rate at which each point tends to a state of rest
    [Range(-0.01f, -0.1f)]
    public float deceleration = -0.1f;

    [Range(0.01f, 0.3f)]
    public float damping = 0.1f;

    private float angle = 0.0f;

    private float angleDiff = 0.0f;

    public GameObject light;

    private int count = 0;



        private Color blue = Color.blue;
        private int center = 50 / 2;
        private int iD = 1;
        private int iGoal = 1;
        private int i = 0;
        private int count2 = 0;
        private int iIters = 0;

        private int jD = 0;
        private int jGoal = -1;
        private int j = 0;
        private int jIters = 0;

        private int iIncrease = 0;
        private int jIncrease = 0;
        private int iIncD = 0;
        private int jIncD = 0;

    void Start()
    {
        Application.targetFrameRate = 60;
        //set the same as xradius for now
        //create a new 2d plane mesh for this object
        shapes3D shapeGen = new shapes3D();
        Mesh mesh = shapeGen.CreatePlane(numSegs, segSize);
        this.GetComponent<MeshFilter>().mesh = mesh;
        //initialize our field points
        this.pointField = initializePoints(numFieldPoints);

        //initialize our height map texture to be the same dimensions as our field points
        heightMap = new Texture2D(numFieldPoints, numFieldPoints);
    }


    // Update is called once per frame
    void Update()
    {
        count++;

        if (count % 1 == 0){
            this.AddForceToWater(this.transform.position, 100f);
        }

        //this loop applies the physics model for each point in our field an updates the heightmap accordingly
        // for (int i = 0; i < numFieldPoints;i++){
        //     for (int j = 0; j < numFieldPoints;j++){
        //         pointField[i,j].move();
        //         heightMap.SetPixel(i,j, pointField[i,j].GetHeightValue());
        //     }
        // }
        if (i < numFieldPoints/2 && count % 1 == 0){
            int indexi = center + i;
            int indexj = center + j;
            if (i == iGoal){
                jD = iD * -1;
                iD = 0;
                iGoal = i + ((2 + iIncrease + iIters) * jD);
                iIters++;
                iIncrease+=iIncD;
                if (iIters % 3 == 0){
                    iIncD++;
                }
            }else if (j == jGoal){
                iD = jD;
                jD = 0;
                jGoal = j + ((2 + jIncrease + jIters) * iD * -1);
                jIters++;
                jIncrease+=jIncD;
                if (jIters % 3 == 0){
                    jIncD++;
                }
            }

            pointField[indexi,indexj].move();
            for (int n = 0; n <= jIncD; n++){
                heightMap.SetPixel(indexi-n,indexj-n, pointField[indexi,indexj].GetHeightValue());
                //heightMap.SetPixel(indexi-n,indexj-n, blue);
            }
            
            
        }
        if (count % 1 == 0){
            i += iD;
            j += jD;
        }
        heightMap.Apply();

        setShaderProperties();
    }

    private void setShaderProperties(){

        this.GetComponent<Renderer>().material.SetFloat("seperation", segSize);
        this.GetComponent<Renderer>().material.SetFloat("totalSize", getSize());
        this.GetComponent<Renderer>().material.SetFloat("_MaxHeight", maxHeight);

        this.GetComponent<Renderer>().material.SetTexture("_Tex", heightMap);
        this.GetComponent<Renderer>().material.SetVector("_BaseColor", primaryCol);
        this.GetComponent<Renderer>().material.SetVector("_LightDir", light.transform.position);
    }

    public void AddForceToWater(Vector3 position, float forceAmount){
        //first rotate the input position to match the rotation of the water
        //ensures we dont get an out of bounds exception and translates position to water
        Vector2 index = getClosestPoint(position);
        pointField[(int)index.x,(int)index.y].addForce(-1 * forceAmount);
    }

    public float getHeightAtPosition(Vector3 position){
        Vector2 closest = getClosestPoint(position);
        return (this.heightMap.GetPixel((int)closest.x, (int)closest.y).r - maxHeight);
    }


    public float getSize(){
        return segSize * numSegs;
    }

    //translates wolrd positions into the closest index on the field points matrix.
    public Vector2 getClosestPoint(Vector3 position){
        float xDiff = position.x - this.transform.position.x + this.getSize()/2.0f;
        float zDiff = position.z - this.transform.position.z + this.getSize()/2.0f;
        float x = (xDiff / (this.getSize())) * numFieldPoints;
        float z = (zDiff / (this.getSize())) * numFieldPoints;

        if (x >= numFieldPoints){
            x = numFieldPoints - 1;
        }
        if (x < 0.0f){
            x = 0.0f;
        }
        if (z >= numFieldPoints){
            z = numFieldPoints - 1;
        }
        if (z < 0.0f){
            z = 0.0f;
        }

        return new Vector2(x, z);
    }

    //initializes field points
    private point[,] initializePoints(int numPoints) {
        //initialize all the points without neighbours
        int counter = 0;
        point[,] points = new point[numPoints,numPoints];

        for (int i = 0; i < numPoints;i++){
            for (int j = 0; j < numPoints; j++){
                counter++;
                points[i,j] = new point(this, 0.0f);
            }
        }
        //now that we have initialized all our points, lets set all their neighbours
        //we have each point "connected" to adjascent points so that we can cascade physic effects
        //over the matrix
        for (int i = 0; i < numPoints;i++){
            for (int j = 0; j < numPoints; j++){
                List<point> neighbours = new List<point>();
                if (i + 1 < numPoints){
                    neighbours.Add(points[i+1,j]);
                    if (j + 1 < numPoints){
                        neighbours.Add(points[i+1,j+1]);
                    }
                    if (j - 1 >= 0){
                        neighbours.Add(points[i+1,j-1]);
                    }
                }
                if (i - 1 >= 0){
                    neighbours.Add(points[i-1,j]);
                    if (j + 1 < numPoints){
                        neighbours.Add(points[i-1,j+1]);
                    }
                    if (j - 1 >= 0){
                        neighbours.Add(points[i-1,j-1]);
                    }
                }
                if (j + 1 < numPoints){
                    neighbours.Add(points[i,j+1]);
                }
                if (j - 1 >= 0){
                    neighbours.Add(points[i,j-1]);
                }
                points[i,j].setNeighbours(neighbours.ToArray());
            }
        }
        return points;
    }
}