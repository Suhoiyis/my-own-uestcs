#include <stdio.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/wait.h>

int main() {
    int *N;
    int shm_id = shmget(IPC_PRIVATE, sizeof(int), IPC_CREAT|0666);
    N = (int*)shmat(shm_id, NULL, 0);
    *N = 0;

    // 启动程序A
    if (fork() == 0) {
        execl("./A", "A", N, NULL);
    }
    
    // 启动程序B
    if (fork() == 0) {
        execl("./B", "B", N, NULL);
    }

    wait(NULL);
    wait(NULL);
    printf("Final N = %d\n", *N);
    
    shmdt(N);
    shmctl(shm_id, IPC_RMID, NULL);
    return 0;
}
