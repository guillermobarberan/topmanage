using System;

class Program
{
    static void Main()
    {
        // Declaración de las variables
        string nombre = "ana";
        string apellido = "ana";

        // Función para verificar si una palabra es palíndroma
        bool EsPalindromo(string palabra)
        {
            int longitud = palabra.Length;
            for (int i = 0; i < longitud / 2; i++)
            {
                if (palabra[i] != palabra[longitud - i - 1])
                {
                    return false;
                }
            }
            return true;
        }

        // Verificación de si el nombre y el apellido son palíndromos
        bool nombreEsPalindromo = EsPalindromo(nombre);
        bool apellidoEsPalindromo = EsPalindromo(apellido);

        // Impresión de resultados
        Console.WriteLine($"El nombre '{nombre}' {(nombreEsPalindromo ? "es" : "no es")} un palíndromo.");
        Console.WriteLine($"El apellido '{apellido}' {(apellidoEsPalindromo ? "es" : "no es")} un palíndromo.");
    }
}
