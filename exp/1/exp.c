#include <stdio.h>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>
#include <stdlib.h>

//#include <errno.h>

//设置缓冲区，假设大小是10，初始化为0（开始时没有产品）
int buffer[10]={0};
//写指针，指向生产者将存放数据的存储单元，初始化为0
int in=0;
//读指针，指向消费者将取数据的存储单元，初始化为0
int out=0;

//设置信号量
sem_t empty;//资源信号量，表示缓存池中空缓冲区数量
sem_t full;//资源信号量，表示缓冲池中满缓冲区数量
pthread_mutex_t mutex;//互斥信号量，实现对缓冲池的互斥使用

FILE *fp;//文件指针，指向生产者读取数据的文件，用于打开文件
int data;

//生产者任务
void* Producer(void* arg){
	int data;
	while(1){//无限循环
		//暂停1秒
		sleep(1);
		//申请资源信号量
		sem_wait(&empty);//P操作
		//申请互斥信号量
		pthread_mutex_lock(&mutex);//P操作
		//写缓冲区（读取文件中数字）
		if(fscanf(fp,"%d",&data)==EOF){
	//循环读取，读到文件末尾时让文件指针回到开始
             fseek(fp,0,SEEK_SET);
			 fscanf(fp,"%d",&data);
		}
		in = in%(10);//因为缓冲区大小是10
		buffer[in] = data;
		printf("生产者 %d 号向 %d 号缓冲区写入数据 %d.\n",*((int*)arg),in,data);
		in++;
		//释放互斥信号量
		pthread_mutex_unlock(&mutex);//V操作
		//释放资源信号量
		sem_post(&full);//V操作
	}
}

//消费者任务
void* Consumer(void* arg){
	while(1){//无限循环
		int data;
		//设置不同的处理速度
		sleep(2);
		//申请资源信号量
		sem_wait(&full);//P操作
		//申请互斥信号量
		pthread_mutex_lock(&mutex);//P操作
		//读缓冲区
		out = out%(10);
		data = buffer[out];
		buffer[out] = 0;
		printf("消费者 %d 号从 %d 号缓冲区读出数据 %d.\n",*((int*)arg),out,data);
		out++;
		//释放互斥信号量
		pthread_mutex_unlock(&mutex);//V操作
		//释放资源信号量
		sem_post(&empty);//V操作
	}
}

int main(){
	//初始化互斥信号量
	pthread_mutex_init(&mutex,NULL);
	int test;
	//初始化资源信号量
	test = sem_init(&empty,0,9);
	if(test != 0){
		printf("Init the empty error.\n");
		exit(0);
	}
	test = sem_init(&full,0,0);
	if(test != 0){
		printf("Init the full error.\n");
		exit(0);
	}
	//打开文件
	fp = fopen("./data.txt","r");
	if(fp == NULL){
		printf("Open the file error.\n");
		exit(1);
	}
	int i,j;
	//创建生产者线程
	pthread_t producer_id[3];
	int pid[3] = {1,2,3};
	for(i=0;i<3;i++){
		//赋予它们ID
	test=pthread_create(&producer_id[i],NULL,Producer,(void*)(&pid[i]));
		if(test != 0){
			printf("Create producer thread %d error.\n",i+1);
			exit(0);
		}
	}
	//创建消费者线程
	pthread_t consumer_id[4];
	int cid[4] = {1,2,3,4};
	for(i=0;i<4;i++){
		//赋予它们ID
	test=pthread_create(&consumer_id[i],NULL,Consumer,(void*)(&cid[i]));
		if(test != 0){
			printf("Create consumer thread %d error.\n",i+1);
			exit(0);
		}
	}
	//线程结束后销毁线程
	pthread_join(producer_id[0], NULL);
	pthread_join(producer_id[1], NULL);
	pthread_join(producer_id[2], NULL);
	pthread_join(consumer_id[0], NULL);
	pthread_join(consumer_id[1], NULL);
	pthread_join(consumer_id[2], NULL);
	pthread_join(consumer_id[3], NULL);

	//释放资源
	fclose(fp);
	pthread_mutex_destroy(&mutex);
	sem_destroy(&empty);
	sem_destroy(&full);
	exit(0);
}