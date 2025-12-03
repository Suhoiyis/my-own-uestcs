package fiveChapter;

interface Collection {
  int MAX_NUM = 100;

  void add(Object objAdd);

  void delete(Object objDelet);

  Object find(Object objFind);
}

public class FIFOQueue implements Collection {
  @Override
  public void add(Object objAdd) {
    // add object code
  }

  @Override
  public void delete(Object objDelet) {
    // delete object code
  }

  @Override
  public Object find(Object objFind) {
    // find object code
    return null;
  }

  public void insert(Object objFind) {
    // insert object code
  }

  public static void main(String args[]) {
    Collection cVar = new FIFOQueue();
    Object objAdd = new Object();
    cVar.add(objAdd);
//    cVar.insert(objAdd);
  }
}
