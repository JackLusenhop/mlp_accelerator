#include <stdio.h>
#include <system.h>
#include <io.h>
#include <unistd.h>

// Using usleep as the delay funciton
int usleep(useconds_t usec);

int main(void)
{
	printf("Application to run the mvm noc \n");

	printf("Sending start input signal\n");
	IOWR(MLP_CONTROLLER_0_BASE, 0, 0x1);
	usleep(10);

	printf("DATA READBACK FROM MLP_CONTROLLER_0_BASE is 0x%x \n",IORD(MLP_CONTROLLER_0_BASE, 0));

	return 0;
}
