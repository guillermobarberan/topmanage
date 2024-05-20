using System;

public class Program
{
    public static void Main()
    {
        // Declaración del arreglo
        int[] arreglo = { 15, 23, 1, 5, 10, 30, 8, 12, 6, 18, 25, 20, 3, 2, 7 };

        // Imprimir el arreglo antes de ordenar
        Console.WriteLine("Arreglo antes de ordenar:");
        ImprimirArreglo(arreglo);

        // Ordenar el arreglo usando QuickSort
        QuickSort(arreglo, 0, arreglo.Length - 1);

        // Imprimir el arreglo después de ordenar
        Console.WriteLine("Arreglo después de ordenar:");
        ImprimirArreglo(arreglo);
    }

    // Método de QuickSort
    static void QuickSort(int[] arreglo, int izquierda, int derecha)
    {
        if (izquierda < derecha)
        {
            // Particionar el arreglo y obtener el índice de partición
            int indiceParticion = Particionar(arreglo, izquierda, derecha);

            // Ordenar recursivamente las dos mitades
            QuickSort(arreglo, izquierda, indiceParticion - 1);
            QuickSort(arreglo, indiceParticion + 1, derecha);
        }
    }

    // Método para particionar el arreglo
    static int Particionar(int[] arreglo, int izquierda, int derecha)
    {
        int pivote = arreglo[derecha];
        int indiceMenor = (izquierda - 1);

        for (int j = izquierda; j < derecha; j++)
        {
            if (arreglo[j] < pivote)
            {
                indiceMenor++;
                Intercambiar(arreglo, indiceMenor, j);
            }
        }

        Intercambiar(arreglo, indiceMenor + 1, derecha);
        return indiceMenor + 1;
    }

    // Método para intercambiar dos elementos en el arreglo
    static void Intercambiar(int[] arreglo, int i, int j)
    {
        int temp = arreglo[i];
        arreglo[i] = arreglo[j];
        arreglo[j] = temp;
    }

    // Método para imprimir el arreglo
    static void ImprimirArreglo(int[] arreglo)
    {
        foreach (var elemento in arreglo)
        {
            Console.Write(elemento + " ");
        }
        Console.WriteLine();
    }
}
