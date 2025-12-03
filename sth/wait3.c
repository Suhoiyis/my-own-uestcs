#include <sys/resource.h>
#include <stdio.h>
#include <stdlib.h>

void wait3_demo() {
    if (fork() == 0) { // 子进程
        sleep(1);
        exit(10);
    } else { // 父进程
        struct rusage usage;
        int status;
        pid_t ret = wait3(&status, 0, &usage);
        if (WIFEXITED(status)) {
            printf("Child %d exited with code %d\n",
                   ret, WEXITSTATUS(status));
        }
    }
}
