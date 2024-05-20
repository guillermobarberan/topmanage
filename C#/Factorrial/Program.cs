using System;

public class Program
{
    public static void Main()
    {
        // Solicitar al usuario que ingrese un número
        Console.Write("Ingrese un número: ");
        int numero = int.Parse(Console.ReadLine());

        // Inicializar la variable factorial
        long factorial = 1;

        // Calcular el factorial
        for (int i = 1; i <= numero; i++)
        {
            factorial *= i;
        }

        // Imprimir el resultado
        Console.WriteLine($"El factorial de {numero} es {factorial}");
    }
}
