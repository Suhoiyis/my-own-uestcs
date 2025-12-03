package HOMEWORK;

class Animal {
    String name;
    Animal(String name) {
        this.name = name;
    }
    public void enjoy() {
        System.out.println("动物" + name + "的叫声……");
    }
}
class Cat extends Animal {
    String eyesColor;
    Cat(String n, String c) {
        super(n);  eyesColor = c;
    }
    @Override
    public void enjoy() {
        System.out.println(eyesColor + "的猫" + name + "喵喵喵喵……");
    }
}
class Dog extends Animal {
    String furColor;
    Dog(String n, String c) {
        super(n);  furColor = c;
    }
    @Override
    public void enjoy() {
        System.out.println(furColor + "的狗" + name + "汪汪汪汪……");
    }
}
class Bird extends Animal {
    Bird() {
        super("Poli");
    }
    @Override
    public void enjoy() {
        System.out.println("鸟儿" + name + "叽叽喳喳……");
    }
}
class AnimalCalls {
    private Animal pet;
    AnimalCalls(Animal pet) {
        this.pet = pet;
    }
    public void myPetEnjoy() {
        pet.enjoy();
    }
}


public class Second3 {
    public static void main(String args[]) {
        Cat c = new Cat("Tom", "蓝色");
        Dog d = new Dog("Ben", "黑色");

        Bird b = new Bird();
        AnimalCalls c1 = new AnimalCalls(c);
        AnimalCalls c2 = new AnimalCalls(d);
        AnimalCalls c3 = new AnimalCalls(b);
        c1.myPetEnjoy();
        c2.myPetEnjoy();
        c3.myPetEnjoy();
    }
}

