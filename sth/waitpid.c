#include <sys/wait.h>
#include <unistd.h>
#include <stdio.h>

void waitpid_demo() {
    pid_t pid = fork();
    if (pid == 0) { // 子进程
        sleep(2);
        printf("Child %d exiting\n", getpid());
        exit(5);
    } else if (pid > 0) { // 父进程
        int status;
        while (1) {
            pid_t ret = waitpid(pid, &status, WNOHANG);
            if (ret == 0) {
                printf("Parent: child still running...\n");
                sleep(1);
            } else if (ret == pid) {
                printf("Child exit code: %d\n", WEXITSTATUS(status));
                break;
            }
        }
    } else {
        perror("fork failed");
    }
}
