package com.mycompany.app;

/**
 * Hello world!
 *
 */
public class App {

    public static void main(String[] args) {
        while (true) {
            System.out.println("Looping...");
            // Optionally, add a small delay to prevent excessive CPU usage.
            try {
                Thread.sleep(1000); // Sleep for 1 second
            } catch (InterruptedException e) {
                // If interrupted, the loop will continue, or you can handle it differently.
                System.err.println("Loop interrupted");
            }

            // you can also add some other code here that you want to run every loop.
        }
    }
}


