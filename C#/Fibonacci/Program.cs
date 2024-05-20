//**2. Dado el siguiente código, https://dotnetfiddle.net/L9Beeb, corregirlo para que devuelva los primeros X números de la secuencia de Fibonacci. ++//
using System;

public class Program
{
    public static void Main()
    {
        int X = 10; // Número de elementos de la secuencia de Fibonacci
        int[] intArray = new int[X];

        // Inicializar los primeros dos elementos de la secuencia
        if (X > 0)
            intArray[0] = 0;
        if (X > 1)
            intArray[1] = 1;

        // Ejecuta la secuencia de Fibonacci
        for (int i = 2; i < X; i++)
        {
            intArray[i] = intArray[i - 1] + intArray[i - 2];
        }

        // Imprimir la secuencia de Fibonacci
        for (int i = 0; i < X; i++)
        {
            Console.Write(intArray[i] + " ");
        }
    }
}