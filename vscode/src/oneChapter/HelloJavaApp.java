package oneChapter;

import java.applet.Applet;
import java.awt.Graphics;

@SuppressWarnings("serial")
public class HelloJavaApp extends Applet {
  @Override
  public void paint(Graphics g) {
    g.drawString("Hello, Java Applet World !", 50, 25);
  }
}
