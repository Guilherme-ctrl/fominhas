import 'package:fominhas/core/utils/converters/date_converter.dart';
import 'package:intl/intl.dart';

class DateConverterImplementation implements IDateConverter {
  @override
  DateTime stringToDateTime(String data) {
    try {
      String format = "dd/MM/yyyy";
      final DateFormat formatter = DateFormat(format);
      return formatter.parse(data);
    } catch (e) {
      throw FormatException("Formato de data inválido: $data. Erro: $e");
    }
  }

  @override
  String formatterDiaMesAno(String data) {
    try {
      DateTime dateTime = DateTime.parse(data);

      // Formata o DateTime para o formato desejado
      return DateFormat("dd/MM/yyyy").format(dateTime);
    } catch (e) {
      return data;
    }
  }
}
