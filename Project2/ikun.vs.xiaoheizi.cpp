#include<stdio.h>
#include<stdlib.h>  //cls 清屏
#include<conio.h> //控制台库
#include<graphics.h>  //easyX图形库，用以插入图片
#include<time.h> //时间函数库
#include <windows.h>  //windows库，Sleep函数
#include<mmsystem.h>  //多媒体播放头文件
#include<string.h>
#pragma comment(lib,"winmm.lib")    //加载多媒体设备接口库文件
using namespace std;
int score = 0;
struct Player {
	int score;
	int rank;
	char name[20];
}role[5];
void get_name(char str[])
{
	char ch;
	int i = 0;
	while ((ch = getchar()) != '\n' && i <= 20)
	{
		str[i++] = ch;
	}
}
void swap(int* a, int* b) {
	int temp = *a;
	*a = *b;
	*b = temp;
}
void bubbleSort(struct Player arr[]) {
	char a[20];
	for (int i = 0; i < 5 - 1; i++) {
		for (int j = 0; j < 5 - i - 1; j++) {
			if (arr[j].score < arr[j + 1].score) {
				swap(&arr[j].score, &arr[j + 1].score);
				strcpy_s(a, arr[j].name);
				strcpy_s(arr[j].name,arr[j+1].name);
				strcpy_s(arr[j + 1].name, a);
			}
		}
	}
}
//枚举
enum you
{
	WIDTH = 1132,
	HEIGHT = 622,//窗口大小
	BASKETBALL_NUM = 150,
	ENEMY_NUM = 10000,
	LEVEL_NUM = 3,
	HEIZI,
	SUSHAN,
	HEIYI,
	HEIER,
	HEIZITOUZI,
	PIKAQIU
};

struct GEGE
{
	int x;
	int y;
	bool live; //是否存活
	int width;
	int height;
	int hp;
	int type;//黑子类型
	int heiziscore;
}ikun, bull[BASKETBALL_NUM],heizi[ENEMY_NUM];
//ikun 篮球 黑子的结构体

//关卡变量
int currentLevel = 1;

struct LevelParams
{
	int enemySpawnInterval;  // 黑子生成时间间隔
	int basketballSpeed;     // 篮球移动速度
};

IMAGE lianxisheng[5];  //背景
IMAGE gege[2];   //ikun
IMAGE basketball[4];   //weapon
IMAGE xiaoheizi[6][2];  //enemy

void loadImg()
{
	loadimage(&lianxisheng[0], "./images/lianxisheng1.png");
	loadimage(&lianxisheng[1], "./images/lianxisheng0.png");
	loadimage(&lianxisheng[2], "./images/lianxisheng2.png");
	loadimage(&lianxisheng[3], "./images/lianxisheng3.png");
	loadimage(&lianxisheng[4], "./images/lianxisheng.png");
	//kunkun
	loadimage(&gege[0], "./images/tieshankao(1.2).png");
	loadimage(&gege[1], "./images/tieshankao（2）.png");
	//篮球
	loadimage(&basketball[0], "./images/basketball0.png");
	loadimage(&basketball[1], "./images/basketball.png");
	//加载黑子
	loadimage(&xiaoheizi[0] [0] , "./images/heizi/yi/heiyi1.png");
	loadimage(&xiaoheizi[0] [1], "./images/heizi/yi/heiyi.1.png");

	loadimage(&xiaoheizi[1][0], "./images/heizi/er/22.png");
	loadimage(&xiaoheizi[1][1], "./images/heizi/er/2.2.png");

	loadimage(&xiaoheizi[2][0], "./images/heizi/heizi/heizi1.png");
	loadimage(&xiaoheizi[2][1], "./images/heizi/heizi/heizi.png");

	loadimage(&xiaoheizi[3][0], "./images/heizi/heizitouzi/heizitouzi.png");
	loadimage(&xiaoheizi[3][1], "./images/heizi/heizitouzi/heizitouzi1.png");

	loadimage(&xiaoheizi[4][0], "./images/heizi/pikaqiu/pikaqiu1.png");
	loadimage(&xiaoheizi[4][1], "./images/heizi/pikaqiu/pikaqiu.png");

	loadimage(&xiaoheizi[5][0], "./images/heizi/sushan/suahn1.png");
	loadimage(&xiaoheizi[5][1], "./images/heizi/sushan/sushan.png");

	loadimage(&basketball[2], "./images/kundan5.png");
	loadimage(&basketball[3], "./images/kundan6.png");
}
//加载照片

void HEIZIHP(int k)
{
	heizi[k].type = HEIZI;
	heizi[k].hp = 3;
	heizi[k].width = heizi[k].height = 100;
	heizi[k].heiziscore = 30;
}
void SUSHANHP(int k)
{
	heizi[k].type = SUSHAN;
	heizi[k].hp = 3;
	heizi[k].width = 100;
	heizi[k].height = 90;
	heizi[k].heiziscore = 30;
}
void HEIYIHP(int k)
{
	heizi[k].type = HEIYI;
	heizi[k].hp = 2;
	heizi[k].width = 75;
	heizi[k].height = 74;
	heizi[k].heiziscore = 20;
}
void HEIERHP(int k)
{
	heizi[k].type = HEIER;
	heizi[k].hp = 2;
	heizi[k].width = heizi[k].height = 75;
	heizi[k].heiziscore = 20;
}
void HEIZITOUZIHP(int k)
{
	heizi[k].type = HEIZITOUZI;
	heizi[k].hp = 1;
	heizi[k].width = 60;
	heizi[k].height = 70;
	heizi[k].heiziscore = 10;
}
void PIKAQIUHP(int k)
{
	heizi[k].type = PIKAQIU;
	heizi[k].hp = 2;
	heizi[k].width = 75;
	heizi[k].height = 68;
	heizi[k].heiziscore = 10;
}

void heiziHP(int i)
{
	if (currentLevel == 1)
	{
		switch (i % 20)
		{
		case 0:
		{
			HEIZIHP(i);
			break;
		}
		case 1: case 18:
		{
			SUSHANHP(i);
			break;
		}
		case 2:case 15:

		{
			HEIYIHP(i);
			break;
		}
		case 3:case 16:

		{
			HEIERHP(i);
			break;
		}
		case 4:case 10:case 11:case 12:case 13:case 14:
		case 5: case 8:case 19:
		case 7:	case 9:
		{
			HEIZITOUZIHP(i);
			break;
		}
		case 6:case 17:
		{
			PIKAQIUHP(i);
			break;
		}
		}
	}
	if (currentLevel == 2)
	{
		switch (i % 20)
		{
		case 0:
		{
			HEIZIHP(i);
			break;
		}
		case 1: case 18:
		{
			SUSHANHP(i);
			break;
		}
		case 2:case 15:case 9:

		{
			HEIYIHP(i);
			break;
		}
		case 3:case 16:case 8:

		{
			HEIERHP(i);
			break;
		}
		case 4:case 10:case 11:case 12:case 13:case 14:
		case 5:case 19:
		{
			HEIZITOUZIHP(i);
			break;
		}
		case 6:case 7:case 17:
		{
			PIKAQIUHP(i);
			break;
		}
		}
	}
	if (currentLevel == 3)
	{
		switch (i % 20)
		{
		case 0:case 19:
		{
			HEIZIHP(i);
			break;
		}
		case 1: case 18:
		{
			SUSHANHP(i);
			break;
		}
		case 2:case 15:case 8:case 9:
        {
			HEIYIHP(i);
			break;
		}
		case 3:case 16:

		{
			HEIERHP(i);
			break;
		}
		case 4:case 10:case 11:case 12:case 13:case 14:
		case 5:
		{
			HEIZITOUZIHP(i);
			break;
		}
		case 6:case 7:case 17:
		{
			PIKAQIUHP(i);
			break;
		}
		}
	}
}

void gameInit()  //初始化游戏数据
{
	loadImg();
	ikun.x = 0;
	ikun.y = HEIGHT / 2-59;
	ikun.live = 1;

	//初始化子弹
	for (int i = 0;i < BASKETBALL_NUM; i++)
	{
		bull[i].x = 0;
		bull[i].y = 0;
		bull[i].live = false;
		bull[i].type = 1;
	}

	//初始化黑子
	for (int i = 0; i < ENEMY_NUM; i++)
	{
		heizi[i].live = false;
		heiziHP(i); 
	}

}

void musicBasketball()
{
	if (bull[1].type % 2 == 1)
	{
		mciSendString("close BGM3", NULL, NULL, NULL);
		//打开音乐
		mciSendString("open music\\只因.mp3 alias BGM3", NULL, NULL, NULL);		//向多媒体设备接口发送字符串（打开音乐）
		//PlaySound("music\\兰亭.wav", NULL, SND_FILENAME | SND_ASYNC | SND_LOOP);

		//播放音乐
		mciSendString("play BGM3", NULL, NULL, NULL);
		//system("pause");

		//repeat重复播放		alias取别名
	}
	if (bull[1].type % 2 == 0)
	{
		mciSendString("close BGM7", NULL, NULL, NULL);
		//打开音乐
		mciSendString("open music\\你干嘛倒放.mp3 alias BGM7", NULL, NULL, NULL);		//向多媒体设备接口发送字符串（打开音乐）
		//PlaySound("music\\兰亭.wav", NULL, SND_FILENAME | SND_ASYNC | SND_LOOP);

		//播放音乐
		mciSendString("play BGM7", NULL, NULL, NULL);
		//system("pause");

		//repeat重复播放		alias取别名
	}
}

void gameDraw()
{
	putimage(0, 0, &lianxisheng[currentLevel]);
	putimage(ikun.x, ikun.y, &gege[0], NOTSRCERASE);
	putimage(ikun.x, ikun.y, &gege[1], SRCINVERT);
	//篮球
	for (int i = 0;i < BASKETBALL_NUM; i++)
	{
		if (bull[i].live&&bull[i].type%2==1)
		{
			putimage(bull[i].x, bull[i].y, &basketball[0], NOTSRCERASE);
			putimage(bull[i].x, bull[i].y, &basketball[1], SRCINVERT);
			break;
		}
		if (bull[i].live && bull[i].type % 2 == 0)
		{
			putimage(bull[i].x, bull[i].y, &basketball[2], NOTSRCERASE);
			putimage(bull[i].x, bull[i].y, &basketball[3], SRCINVERT);
			break;
		}
	}
	//画黑子
	for (int i = 0; i < ENEMY_NUM; i++)
	{
		if (heizi[i].live)
		{
			if (heizi[i].type == HEIYI)
			{
				putimage(heizi[i].x, heizi[i].y, &xiaoheizi[0][0], NOTSRCERASE);
				putimage(heizi[i].x, heizi[i].y, &xiaoheizi[0][1], SRCINVERT);
			}
			if (heizi[i].type == HEIER)
			{
				putimage(heizi[i].x, heizi[i].y, &xiaoheizi[1][0], NOTSRCERASE);
				putimage(heizi[i].x, heizi[i].y, &xiaoheizi[1][1], SRCINVERT);
			}
			if (heizi[i].type == HEIZI)
			{
				putimage(heizi[i].x, heizi[i].y, & xiaoheizi[2][0], NOTSRCERASE);
				putimage(heizi[i].x, heizi[i].y, &xiaoheizi[2][1], SRCINVERT);
			}
			if (heizi[i].type == HEIZITOUZI)
			{
				putimage(heizi[i].x, heizi[i].y, &xiaoheizi[3][0], NOTSRCERASE);
				putimage(heizi[i].x, heizi[i].y, &xiaoheizi[3][1], SRCINVERT);
			}
			if (heizi[i].type == PIKAQIU)
			{
				putimage(heizi[i].x, heizi[i].y, &xiaoheizi[4][0], NOTSRCERASE);
				putimage(heizi[i].x, heizi[i].y, &xiaoheizi[4][1], SRCINVERT);
			}
			if (heizi[i].type == SUSHAN)
			{
				putimage(heizi[i].x, heizi[i].y, &xiaoheizi[5][0], NOTSRCERASE);
				putimage(heizi[i].x, heizi[i].y, &xiaoheizi[5][1], SRCINVERT);
			}
		}
	}
}
//游戏绘制函数

void creatbasketball()
{
	for (int i = 0;i < BASKETBALL_NUM; i++)
	{
		if (!bull[i].live)
		{
			musicBasketball();
			bull[i].x = ikun.x + 65;
			bull[i].y = ikun.y + 10;
			bull[i].live = true;

			//PlaySound(TEXT("D:\\VScode C\\gege\\Project2\\Project2\\music\\唱跳rap篮球.wav"), NULL, SND_FILENAME | SND_ASYNC | SND_LOOP);


			//mciSendString("open music\\只因.mp3 alias JI", NULL, NULL, NULL);
			//mciSendString("play JI", NULL, NULL, NULL);
			//mciSendString("close JI", NULL, NULL, NULL);

			break;
		}
	}
}

void ballmove(int speed)
{
	for (int i = 0;i < BASKETBALL_NUM; i++)
	{
		if (bull[i].live && bull[i].type % 2 == 1)
		{
			bull[i].x += speed;

			if (bull[i].x + 15 > WIDTH)
				bull[i].live = false;
		}
		if (bull[i].live && bull[i].type % 2 == 0)
		{
			bull[i].x += speed;

			if (bull[i].x + 50 > WIDTH)
				bull[i].live = false;
		}
	}
}

bool Timer(int ms, int id)
{
	static DWORD t[10];
	if (clock() - t[id] > ms)
	{
		t[id] = clock();
		return true;
	}
	return false;
}

//角色移动，获取键盘消息
void ikunmove(float speed)
{
#if 0
	if (_kbhit())
	{
		char key = _getch();
		switch (key)
		{
		case'w':
		case'W':
			ikun.y -= speed;
			break;
		case'a':
		case'A':
			ikun.x -= speed;
			break;
		case's':
		case'S':
			ikun.y += speed;
			break;
		case'd':
		case'D':
			ikun.x += speed;
			break;
		}
	}

#elif 1  //windows函数  GetAsyncKeyState非阻塞函数
		 //字母按键必须用大写，（可同时检测大小写），若小写则什么也检测不到
	if (GetAsyncKeyState(VK_UP) || GetAsyncKeyState('W'))
	{
		if (ikun.y > 0)
			ikun.y -= speed;
	}
	if (GetAsyncKeyState(VK_LEFT) || GetAsyncKeyState('A'))
	{
		if (ikun.x > 0)
			ikun.x -= speed;
	}
	if (GetAsyncKeyState(VK_DOWN) || GetAsyncKeyState('S'))
	{
		if (ikun.y < 540)
			ikun.y += speed;
	}
	if (GetAsyncKeyState(VK_RIGHT) || GetAsyncKeyState('D'))
	{
		if (ikun.x < 1047)
			ikun.x += speed;
	}

#endif //0

	//mciSendString("open music\\只因.mp3 alias JI", NULL, NULL, NULL);
	
	if (GetAsyncKeyState(VK_SPACE) && Timer(300,0))
	{	
		if (bull[1].type % 2 == 1)
		creatbasketball();
		
		if (bull[1].type % 2 == 0&&score>=100)
		{
			creatbasketball();
		    score -= 100;
		}
		//mciSendString("play JI", NULL, NULL, NULL);
		
		//Sleep(280);
		//mciSendString("close JI", NULL, NULL, NULL);

		//PlaySound(TEXT("D:\\VScode C\\gege\\Project2\\Project2\\music\\唱跳rap篮球.wav"), NULL, SND_FILENAME | SND_ASYNC | SND_LOOP);
		
	}
	if (GetAsyncKeyState('Q') && Timer(300, 3))
	{
		for (int i = 0;  i< BASKETBALL_NUM; i++)
		{
			bull[i].type += 1;
		}
	}
}

LevelParams levelData[] = {
	{700, 2},  
	{500, 2},
	{200, 3},
};

void createheizi()
{
	for (int i = 0; i < ENEMY_NUM; i++)
	{
		if (!heizi[i].live)
		{
			heizi[i].live = true;
			heizi[i].x = 1132;
			heizi[i].y = rand() % (HEIGHT-60);
			heiziHP(i);
			break;
		}
	}
}

void heizimove(int speed)
{
	for (int i = 0; i < ENEMY_NUM; i++)
	{
		if (heizi[i].live)
		{
			heizi[i].x -= speed;
			if (heizi[i].x < 0)
			{
				heizi[i].live = false;
			}
		}
	}
}

void death() 
{
	for (int i = 0; i < ENEMY_NUM; i++)
	{
		if (!heizi[i].live)
			continue;
		if (ikun.x + 65 > heizi[i].x && ikun.x < heizi[i].x + heizi[i].width-30
			&& ikun.y + 100>heizi[i].y && ikun.y < heizi[i].y + heizi[i].height-15)
			 // Sleep(500);         //停止1.5s
		ikun.live = 0;
	}
}

//在指定的位置显示分数
void showScore(int x, int y, int score)
{
	TCHAR time_text[50];
	_stprintf_s(time_text, _T("律师函:%d"), score);
	settextstyle(40, 0, _T("微软雅黑"));
	outtextxy(x, y, time_text);
}

void vs()
{
	for (int i = 0; i < ENEMY_NUM; i++)
	{
		if (!heizi[i].live)
			continue;
		for (int g = 0; g < BASKETBALL_NUM; g++)
		{
			if (!bull[g].live)
				continue;
			if (bull[g].x + 34 > heizi[i].x && bull[g].x < heizi[i].x + heizi[i].width
				&& bull[g].y + 35>heizi[i].y && bull[g].y < heizi[i].y + heizi[i].height&&bull[i].type%2==1)
			{
				bull[g].live = false;
				heizi[i].hp--;
			}
			if (bull[g].x + 50 > heizi[i].x && bull[g].x < heizi[i].x + heizi[i].width
				&& bull[g].y + 51>heizi[i].y && bull[g].y < heizi[i].y + heizi[i].height && bull[i].type % 2 == 0)
			{
				for (int i = 0; i < BASKETBALL_NUM; i++)
				{
					if (heizi[i].x + 200 > bull[g].x && heizi[i].x< bull[g].x + 200
						&& heizi[i].y + 150>bull[g].y && heizi[i].y < bull[g].y + 150)
					{
						bull[g].live = false;
						heizi[i].hp -= 3;
					}
				}
					
			}
		}
		if (heizi[i].hp <= 0)
		{
			heizi[i].live = false;
			score += heizi[i].heiziscore;
			/*switch (i % 20)
			{
			case 0:
			{
				score = score + 30;
				break;
			}
			case 1: case 18:
			{
				score = score + 30;
				break;
			}
			case 2:case 15:

			{
				score = score + 20;
				break;
			}
			case 3:case 16:

			{
				score = score + 20;
				break;
			}
			case 4:case 10:case 11:case 12:case 13:case 14:
			case 5: case 8:case 19:
			case 7:	case 9:
			{
				score = score + 10;
				break;
			}
			case 6:case 17:
			{
				score = score + 20;
				break;
			}*/
		}
	}
	// 判断是否达到切换关卡的条件
	if (score < 500)
	{
		currentLevel = 1;
	}
	if (score >= 500 && score<1000)  // 当成功击败10个黑子时切换到下一个关卡,并且防止关卡数超出范围
	{
		currentLevel=2;  // 切换到下一个关卡
	}
	if (score >= 1000)  // 当成功击败10个黑子时切换到下一个关卡,并且防止关卡数超出范围
	{
		currentLevel = 3;  // 切换到下一个关卡
	}
}

void musicBackground()
{
	if (currentLevel == 1)
	{
		mciSendString("close BGM5", NULL, NULL, NULL);
		mciSendString("close BGM6", NULL, NULL, NULL);
		//打开音乐
		mciSendString("open music\\【蔡徐坤】鸡花瓷.mp3 alias BGM1", NULL, NULL, NULL);		//向多媒体设备接口发送字符串（打开音乐）
		//PlaySound("music\\【蔡徐坤】鸡花瓷.mp3", NULL, SND_FILENAME | SND_ASYNC | SND_LOOP);

		//播放音乐
		mciSendString("play BGM1 repeat", NULL, NULL, NULL);
		//system("pause");

		//repeat重复播放		alias取别名
	}
	if (currentLevel == 2)
	{
		mciSendString("close BGM1", NULL, NULL, NULL);
		mciSendString("close BGM6", NULL, NULL, NULL);
		//打开音乐
		mciSendString("open music\\【蔡徐坤】兰亭鸡序.mp3 alias BGM5", NULL, NULL, NULL);		//向多媒体设备接口发送字符串（打开音乐）
		//PlaySound("music\\【蔡徐坤】兰亭鸡序.mp3", NULL, SND_FILENAME | SND_ASYNC | SND_LOOP);

		//播放音乐
		mciSendString("play BGM5 repeat", NULL, NULL, NULL);
		//system("pause");

		//repeat重复播放		alias取别名
	}
	if (currentLevel == 3)
	{
		mciSendString("close BGM5", NULL, NULL, NULL);
		//打开音乐
		mciSendString("open music\\只因你太美.mp3 alias BGM6", NULL, NULL, NULL);		//向多媒体设备接口发送字符串（打开音乐）
		//PlaySound("music\\只因你太美.mp3", NULL, SND_FILENAME | SND_ASYNC | SND_LOOP);

		//播放音乐
		mciSendString("play BGM6 repeat", NULL, NULL, NULL);
		//system("pause");

		//repeat重复播放		alias取别名
	}
}

void musicDeath()
{
	//打开音乐
	mciSendString("open music\\你干嘛哎哟.mp3 alias BGM2", NULL, NULL, NULL);		//向多媒体设备接口发送字符串（打开音乐）
	//PlaySound("music\\兰亭.wav", NULL, SND_FILENAME | SND_ASYNC | SND_LOOP);

	//播放音乐
	mciSendString("play BGM2", NULL, NULL, NULL);
	//system("pause");

	//repeat重复播放		alias取别名
}

void rank(int score)
{

}

//鼠标是否在某个矩形区域
bool isInRect(ExMessage* msg, int x, int y, int w, int h) {
	if (msg->x > x && msg->x < x + w && msg->y > y && msg->y < y + h) {
		return true;
	}
	return false;
}
//z

void startupScene(ExMessage* msg, int* p) {
	if (msg->message == WM_LBUTTONDOWN) {
		//开始
		if (isInRect(msg, 473, 230, 138, 71)) {
			*p = 0;
			gameInit();
		}
		else if (isInRect(msg, 467, 413, 138, 71)) {
			exit(-1);
		}
	}

}//z

void endScene(ExMessage* msg,int* q,int* p) {
	if (msg->message == WM_LBUTTONDOWN) {
		//开始
		if (isInRect(msg, 794, 521, 69, 41)) {
			*q = 0;
			gameInit();
		}
		else if (isInRect(msg, 985, 521, 69, 41)) {
			*p = 0;
			*q = 0;

		}
	}

}//z

int main() 
{	
	FILE *filePointer;
	filePointer = fopen("飞鸡大战.txt.txt", "w");
	initgraph(WIDTH, HEIGHT);
	gameInit();
	
	//双缓冲绘图
	BeginBatchDraw();
	//处理消息z
	ExMessage msg;
	int z = 1;
	int k = 0;//用来弄结构体的参数
	while (z&&k<=4) {
		int m = 1;
		int y = 1;
		int x = 1;
		printf("输入您的大名,点击开始即可进入游戏,和来自全球的真IKUN同台竞技！");////////////////////////////////////
		get_name(role[k].name);
		while (x)
		{
			
			while (y) {
				putimage(0, 0, &lianxisheng[0]);
				FlushBatchDraw();
				while (peekmessage(&msg, EM_MOUSE)) {
					startupScene(&msg, &y);
				}
			};
			
			musicBackground();
			gameDraw();
			showScore(500, 0, score);
			FlushBatchDraw();
			ikunmove(1);
			ballmove(levelData[currentLevel - 1].basketballSpeed);
			if (Timer(levelData[currentLevel - 1].enemySpawnInterval, 1))
			{
				createheizi();
			}

			if (Timer(10, 2))
			{
				heizimove(1);
			}

			death();
			vs();


			if (ikun.live == 0)
			{
				x--;
				role[k].score = score;////////////////////////////////////////////////////////////////////////////
				score = 0;
			}
		}
		if (currentLevel == 1)
		{
			mciSendString("close BGM1", NULL, NULL, NULL);
		}
		if (currentLevel == 2)
		{
			mciSendString("close BGM5", NULL, NULL, NULL);
		}
		if (currentLevel == 3)
		{
			mciSendString("close BGM6", NULL, NULL, NULL);
		}
		musicDeath();		//死亡播报：你干嘛
		Sleep(2500);
		while (m) {
			putimage(0, 0, &lianxisheng[4]);
			FlushBatchDraw();
			while (peekmessage(&msg, EM_MOUSE)) {
				endScene(&msg,&m,&z);
			}
		};
		k++;
	}
	EndBatchDraw();
	system("cls");
	
	//printf("胜败乃坤家常事，ikun请重新来过");
	bubbleSort(role);
	fprintf(filePointer,"排名  IKUN  得分\n");
	printf("排名  IKUN  得分\n");
	
	for (int i = 0; i <= 4; i++)
	{
		fprintf(filePointer, "%.4d %s %.4d\n", i + 1, role[i].name, role[i].score);
	}
	fclose(filePointer);
	for (int i = 0; i <= 4; i++)
	{
		printf("%.4d %s %.4d\n",i+1,role[i].name,role[i].score);
	}
	return 0;
}