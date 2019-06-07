#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <mach/mach.h>
#include <IOKit/IOKitLib.h>

int main(int argc, char** argv, char** envp)
{
	if (argc < 2)
	{
		printf("Incorrect Usage\nUsage: ioclient [client name]\n");
		return -1;
	}
	char* client_name = argv[1];
	
	kern_return_t kr;
	NSMutableOrderedSet* foundServices = [NSMutableOrderedSet new];

	//loop through every IOService:
	io_iterator_t services;
	kr = IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IOService"), &services);
	io_service_t service;
	while ((service = IOIteratorNext(services)))
	{
		//get the service's name:
		io_name_t service_name;
		IORegistryEntryGetName(service, service_name);

		//open first 10 clients:
		io_connect_t conns[10];
		for (int i = 0; i < 10; i++)
		{
			conns[i] = IO_OBJECT_NULL;
			kr = IOServiceOpen(service, mach_task_self(), i, &(conns[i]));
		}

		//loop through registry entries:
		io_iterator_t children;
		kr = IORegistryEntryGetChildIterator(service, kIOServicePlane, &children);
		if (kr != KERN_SUCCESS)
			continue;
		
		io_registry_entry_t child;
		while ((child = IOIteratorNext(children)))
		{
			io_name_t child_name;
			IORegistryEntryGetName(child, child_name);
			if (strcmp(child_name, client_name) == 0)
			{
				[foundServices addObject:[NSString stringWithUTF8String:service_name]];
			
				//we found the service, no need to look through more children
				break;
			}
		}
		
		//close clients again:
		for (int i = 0; i < 10; i++)
		{
			if (conns[i])
				IOServiceClose(conns[i]);
		}

		//release our children iterator:
		IOObjectRelease(children);
	}
	//release our children iterator:
	IOObjectRelease(services);

	//print all matching services:
	if (foundServices.count == 0)
	{
		printf("Unable to find client: %s\n", client_name);
	}
	else
	{
		for (int i = 0; i < foundServices.count; i++)
		{
			printf("%s\n", [foundServices[i] UTF8String]);
		}
	}

	return 0;
}
