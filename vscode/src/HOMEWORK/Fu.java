package HOMEWORK;

class Fu {
    boolean show(char a) {
        System.out.println(a); return true;
    }
}

class Demo extends Fu {
    public static void main(String[] args) {
        int i = 0;
        Fu f = new Fu();
        Fu f2 = new Demo();
        for (f.show('A'); i < 2 || f2.show('B'); f.show('C')) {
            i++;
            f2.show('D');
        }
    }

@Override
boolean show(char a) {
    System.out.println(a);
    return false;
}
}

