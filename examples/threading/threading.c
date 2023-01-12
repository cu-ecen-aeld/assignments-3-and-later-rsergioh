#include "threading.h"
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

// Optional: use these functions to add debug or error prints to your application
#define DEBUG_LOG(msg,...)
//#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

void* threadfunc(void* thread_param)
{

    // TODO: wait, obtain mutex, wait, release mutex as described by thread_data structure
    // hint: use a cast like the one below to obtain thread arguments from your parameter
    //struct thread_data* thread_func_args = (struct thread_data *) thread_param;
    
    struct thread_data* thread_func_args = (struct thread_data *) thread_param;
    thread_func_args->thread_complete_success = true;
    int time_to_obtain_us = thread_func_args->time_to_obtain_ms*1000;
    int time_to_release_us = thread_func_args->time_to_release_ms*1000;    
    int mutex_status;
    
    usleep(time_to_obtain_us);
    mutex_status = pthread_mutex_lock(thread_func_args->mutex);
    if (mutex_status != 0)
    {
    	thread_func_args->thread_complete_success = false;
    	ERROR_LOG("pthread_mutex_lock");
    }
    else
    {
		usleep(time_to_release_us);
		mutex_status = pthread_mutex_unlock(thread_func_args->mutex);
		if (mutex_status != 0)
		{
			thread_func_args->thread_complete_success = false;
			ERROR_LOG("pthread_mutex_unlock");
		}
	}
	    
    return thread_param;
}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    /**
     * TODO: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.
     *
     * See implementation details in threading.h file comment block
     */ 
    
    struct thread_data *test_thread = malloc(sizeof(*test_thread));
    //void *thread_retvalue;
    int thread_status;
    bool retvalue = true;
    
    test_thread->thread = thread;
    test_thread->mutex = mutex;
    test_thread->time_to_obtain_ms = wait_to_obtain_ms;
    test_thread->time_to_release_ms = wait_to_release_ms;
    
    thread_status = pthread_create(test_thread->thread, NULL, threadfunc, (void *) test_thread);
    if (thread_status != 0)
    {
    	retvalue = false;
    	ERROR_LOG("pthread_create");
    }
     
    return retvalue;
}

