using System;

public class Program
{
    public static void Main()
    {
        // Arreglo de números a ordenar
        int[] arr = { 10, 55, 3, 74, 21 };

        Console.WriteLine("Arreglo original:");
        ImprimirArreglo(arr);

        // Método de ordenamiento burbuja
        for (int i = 0; i < arr.Length - 1; i++)
        {
            for (int j = 0; j < arr.Length - 1 - i; j++)
            {
                if (arr[j] > arr[j + 1])
                {
                    // Intercambio de elementos
                    int temp = arr[j];
                    arr[j] = arr[j + 1];
                    arr[j + 1] = temp;
                }

                // Imprimir el estado del arreglo en cada iteración
                Console.WriteLine($"Iteración {i}.{j + 1}:");
                ImprimirArreglo(arr);
            }
        }

        Console.WriteLine("Arreglo ordenado:");
        ImprimirArreglo(arr);
    }

    // Método para imprimir el arreglo
    public static void ImprimirArreglo(int[] arr)
    {
        foreach (int num in arr)
        {
            Console.Write(num + " ");
        }
        Console.WriteLine();
    }
}
