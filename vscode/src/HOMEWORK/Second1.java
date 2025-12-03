package HOMEWORK;

class worker {
    int num;

    worker() {
        num += 5;
    }

    worker(int n) {
        num = n;
    }

    void workShow() {
        System.out.println("Inside worker method, num=" + num);
    }
}

class programmer extends worker {
    int num = 1;
    programmer(int n) {
        num += n;
    }
    void workShow() {
        System.out.println("Inside programmer method, num=" + num + ", super.num=" + super.num);
    }
}

public class Second1 {
    public static void main(String args[]) {
        worker a = new programmer(10);
        a.workShow();
    }
}


