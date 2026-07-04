/// Validadores reutilizables para todos los formularios de la app
/// (Login, Registro, Finca, Parcela, Cultivo).
class Validators {
  Validators._();

  static String? requerido(String? value, {String campo = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$campo es obligatorio';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa tu correo';
    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Correo no válido';
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
    if (value.length < minLength) {
      return 'Debe tener al menos $minLength caracteres';
    }
    return null;
  }

  static String? confirmarPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Confirma tu contraseña';
    if (value != original) return 'Las contraseñas no coinciden';
    return null;
  }

  /// Celular ecuatoriano: 10 dígitos, empieza en 09 (Claro/Movistar/CNT).
  static String? telefono(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa tu teléfono';
    final digits = value.trim();
    if (!RegExp(r'^09\d{8}$').hasMatch(digits)) {
      return 'Celular ecuatoriano inválido (10 dígitos, empieza en 09)';
    }
    return null;
  }

  /// Valida cédula ecuatoriana con el algoritmo de módulo 10.
  static String? cedulaEcuatoriana(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa tu cédula';
    final cedula = value.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(cedula)) return 'Debe tener 10 dígitos';

    final provincia = int.parse(cedula.substring(0, 2));
    if (provincia < 1 || provincia > 24) return 'Cédula no válida';

    final tercerDigito = int.parse(cedula[2]);
    if (tercerDigito > 6) return 'Cédula no válida';

    final coeficientes = [2, 1, 2, 1, 2, 1, 2, 1, 2];
    var suma = 0;
    for (var i = 0; i < 9; i++) {
      var valor = int.parse(cedula[i]) * coeficientes[i];
      if (valor >= 10) valor -= 9;
      suma += valor;
    }
    final verificador = (10 - (suma % 10)) % 10;
    if (verificador != int.parse(cedula[9])) return 'Cédula no válida';
    return null;
  }

  static String? numeroPositivo(String? value, {String campo = 'El valor'}) {
    if (value == null || value.trim().isEmpty) return '$campo es obligatorio';
    final n = double.tryParse(value.trim());
    if (n == null) return '$campo debe ser numérico';
    if (n <= 0) return '$campo debe ser mayor a 0';
    return null;
  }

  static String? fechaNoFutura(DateTime? value, {String campo = 'La fecha'}) {
    if (value == null) return '$campo es obligatoria';
    if (value.isAfter(DateTime.now())) return '$campo no puede ser futura';
    return null;
  }
}
