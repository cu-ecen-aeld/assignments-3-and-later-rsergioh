#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <syslog.h>
#include <string.h>
#include <stdio.h>

#define DEBUG_PRIORITY       LOG_USER|LOG_DEBUG
#define ERROR_PRIORITY       LOG_USER|LOG_ERR 

int main(int argc, char **argv)
{
    int retval = 0;
    int inputStringSize = 0;
    int fd;
    ssize_t writeStatus;
    
    // Setup logging
    openlog("writer", LOG_CONS, LOG_USER);
    
    // Check that two arguments were given
    if ( (argc != 3) ) 
    {
        syslog(ERROR_PRIORITY, "Incorrect arguments. Number of arguments given: %d. Write string of size %ld.", argc, sizeof(argv[2]));
        retval = 1;
    }
    else if ( (0 == strlen(argv[2])) && (0 == strlen(argv[2])) )
    {
    	syslog(ERROR_PRIORITY, "Incorrect arguments. Filename or write string are invalid.");
        retval = 1;
	}
    
    if (0 == retval)
    {
        char *filename = argv[1];
        char *inputString = argv[2];
        inputStringSize = strlen(inputString);
        
        fd = creat(filename, 0664);
        
        if (-1 == fd)
        {
            syslog(ERROR_PRIORITY, "Failed to open or create file. Verify path.");
            retval = 1;
        }
        else
        {
            syslog(DEBUG_PRIORITY, "Opening file %s.", filename);
            writeStatus = write(fd, inputString, inputStringSize);
            
            if (-1 == writeStatus)
            {
                  syslog(ERROR_PRIORITY, "Failed to write file.");
                  retval = 1;
            }
            else
            {
                syslog(DEBUG_PRIORITY, "Writing %s to %s", inputString, filename);
            }
        }
    }

    return retval;
        
}
