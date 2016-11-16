/*
* Author: Alan Irwin
* Description: For implementation on ARM Processor in SOC
*		Receives data from FPGA, and sorts data.
*		Dumps sorted data into DDR3 Memory
*/

// Libraries

// Definitions
#define FALSE 0
#define false FALSE
#define TRUE !FALSE
#define true TRUE

// Structs
typedef struct
{
	float distance;
	int index;
}dist;

// Prototypes
void dist_init(dist* arr, int len);
int dist_insert(dist* arr, int maxlen, int curlen, dist inval);

// Start of Code
void main(void)
{
	dist tmpval;
	int curlength;
	int maxlength;
	int flag = false;
	int datasetflag = false;

	while(1)
	{
		// Poll on FPGA flag for new dataset
		flag = false;
		while (!flag){
			//TODO
			flag = false;
		}
		// Get N (length of array)
		//TODO
		maxlength = 0;
		// Initialize Array
		dist distanceArr[maxlength];
		curlength = dist_init(&distanceArr, maxlength);

		datasetflag = false;
		while(!datasetflag)
		{
			// Poll on FPGA flag for new value
			flag = false;
			while (!flag){
				//TODO
				flag = false;
			}

			// Get and insert new value
			//TODO
			tmpval.index = 0;
			//TODO
			tmpval.distance = 0;
			curlength = dist_insert(&distanceArr, maxlength, curlength, tmpval);

			// Send flag to FPGA for new value
			//TODO
			// Check for flag from FPGA that dataset is complete
			// TODO
			datasetflag = false;
		}
		// Dump array into DDR3
		// TODO
	}

	return;
}//end main

/*
* Initializes array to have negative values for optimized sorting
*
* @param dist* arr
*		pointer to array of dist structs
* @param int len
*		length of array
*
* @return int
*		new current length of the array
*/
int dist_init(dist* arr, int len)
{
	for (int i = 0; i < len; i++)
	{
		arr[i].index = -1;
		arr[i].distance = -1;
	}
	return 0;
}//end dist_init

/*
* Inserts value into array to keep array sorted by distance
*
* @param dist* arr
*		pointer to array of dist structs
* @param int maxlen
*		maximum length of array (based on allocated space)
* @param int curlen
*		current length of array (based on values)
* @param dist inval
*		new value to insert into array
*
* @return int
*		New length of array
*/
int dist_insert(dist* arr, int maxlen, int curlen, dist inval)
{
	int i = -1;

	while (i < curlen && i < maxlen){
		i++;
		// Find spot where to insert new value
		if (inval.distance < arr[i].distance)
		{
			// Shift contents of array up to make room for new value
			for (int x = curlen; x > i; x--)
			{
				arr[x] = arr[x-1];
			}
			// insert new value
			arr[i] = inval;
		}
	}
	return curlen + 1;
}//end dist_insert
