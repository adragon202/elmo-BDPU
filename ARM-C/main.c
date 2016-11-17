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
#define TRUE 1
#define true TRUE
#define FLAG_FPGA_DATARDY 1		// data ready from FPGA
#define FLAG_ARM_SORTED 2		// data sorted on ARM
#define FLAG_FPGA_COMPLETE 4	// dataset complete from FPGA
#define FLAG_FPGA_INIT 8		// new dataset for FPGA is ready

// Macros
#define ReceiveInt(inval, outval)\
	outval = 0;\
	inval = XUartPs_RecvByte(STDOUT_BASEADDRESS);\
	outval = (u32) inval;\
	inval = XUartPs_RecvByte(STDOUT_BASEADDRESS);\
	outval |= ((u32) inval) << 4;\
	inval = XUartPs_RecvByte(STDOUT_BASEADDRESS);\
	outval |= ((u32) inval) << 8;\
	inval = XUartPs_RecvByte(STDOUT_BASEADDRESS);\
	outval |= ((u32) inval) << 16;
#define SendInt(inval, outval)\
	outval = 0;\
	outval = (char) (inval);\
	XUartPs_SendByte(STDOUT_BASEADDRESS, outval);\
	outval = (char) (inval >> 4);\
	XUartPs_SendByte(STDOUT_BASEADDRESS, outval);\
	outval = (char) (inval >> 8);\
	XUartPs_SendByte(STDOUT_BASEADDRESS, outval);\
	outval = (char) (inval >> 16);\
	XUartPs_SendByte(STDOUT_BASEADDRESS, outval);

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
	//Registers for for FPGA I/O
	//TODO
	u32* lengthreg		= NULL; //used to set maxlength
	u32* indexreg		= NULL; //used to set tmpindex
	u32* distancereg	= NULL; //used to set tmpdistance
	u32* flagreg		= NULL; //used to pass flags between ARM and FPGA
	// DDR3 Base Pointer
	u32* ddr3			= XPAR_PS7_DDR_0_S_AXI_BASEADDR;
	u32* ddr3_max		= XPAR_PS7_DDR_0_S_AXI_HIGHADDR;
	// Data receiving values
	char uart_byte;
	u32 uart_int;

	while(true)
	{
		/************************************************************************/
		/**************************Receive Data by UART**************************/
		/************************************************************************/
		init_platform();
		// Await 0x00 to begin data transfer initialization
		while(XUartPs_RecvByte(STDOUT_BASEADDRESS) != 0);
		// Send 0x11 to confirm data transfer intialization
		XUartPs_SendByte(STDOUT_BASEADDRESS, 0x11);

		// Start receiving data array
		flag = false;
		ddr3 += 8; //skip first two values until end of array
		while(flag != 3)
		{
			ReceiveInt(uart_byte, uart_int);

			// Check for first end of message value
			if (uart_int == 0xFFFFFFFF && flag == false){
				flag = 1;
			// Check for second end of message value
			}else if (uart_int == 0x00000000 && flag == 1){
				flag = 2;
			// Check for final end of message value
			}else if (uart_int == 0xdeadbeef && flag == 2){
				flag = 3;
			}else{
				flag = false;
			}
			//write to DDR3
			if (ddr3 < ddr3_max){
				*ddr3 = uart_int;
				ddr3++;
			}
		}

		// Get dimensions of array
		ddr3 = XPAR_PS7_DDR_0_S_AXI_BASEADDR;
		XUartPs_SendByte(STDOUT_BASEADDRESS, 0x12);
		// Get Vector Width Value
		ReceiveInt(uart_byte, uart_int);
		//write to DDR3
		if (ddr3 < ddr3_max){
			*ddr3 = uart_int;
			ddr3++;
		}
		// Get index count Value
		ReceiveInt(uart_byte, uart_int);
		// Get N (length of array)
		maxlength = uart_int;
		//write to DDR3
		if (ddr3 < ddr3_max){
			*ddr3 = uart_int;
			ddr3++;
		}
		// Send confirmation of receipt
		XUartPs_SendByte(STDOUT_BASEADDRESS, 0x13);

		cleanup_platform();
		
		/************************************************************************/
		/***********************Initialize Working Dataset***********************/
		/************************************************************************/
		// Poll on FPGA flag for new dataset
		*flagreg = *flagreg & FLAG_FPGA_INIT;
		// Initialize Array
		dist distanceArr[maxlength];
		curlength = dist_init(&distanceArr, maxlength);


		/************************************************************************/
		/**************************Get and Sort Dataset**************************/
		/************************************************************************/
		datasetflag = false;
		while(!datasetflag)
		{
			// Poll on FPGA flag for new value
			flag = false;
			while (!flag){
				flag = *flagreg & FLAG_FPGA_DATARDY;
			}

			// Get and insert new value
			tmpval.index = *indexreg;
			tmpval.distance = *distancereg;
			curlength = dist_insert(&distanceArr, maxlength, curlength, tmpval);

			// Send flag to FPGA for new value
			*flagreg = *flagreg & !FLAG_FPGA_DATARDY; //unset dataready
			*flagreg = *flagreg | FLAG_ARM_SORTED; //set data sorted
			// Check for flag from FPGA that dataset is complete
			datasetflag = *flagreg & FLAG_FPGA_COMPLETE;
		}

		/************************************************************************/
		/***********************Make Data Available for PC***********************/
		/************************************************************************/
		// Return Data by UART
		init_platform();
		for (int i = 0; i < curlength; ++i)
		{
			SendInt(distanceArr[i].index, uart_byte);
			SendInt(distanceArr[i].distance, uart_byte);
		}
		cleanup_platform();
		// Dump array into DDR3
		/*int ddr3count = 0;
		for (int i = 0; i < curlength; ++i)
		{
			ddr3[ddr3count] = distanceArr[i].index;
			ddr3[ddr3count+1] = distanceArr[i].distance;
			ddr3count++;
		}*/
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
