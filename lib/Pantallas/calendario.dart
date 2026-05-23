import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class calendar extends StatefulWidget {
  const calendar({super.key, required this.titulo});

  final String titulo;

  @override
  State<calendar> createState() => _CalendarState();
}

class _CalendarState extends State<calendar> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  final TextEditingController _nombreEvento = TextEditingController();

  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now().add(const Duration(hours: 1));

  bool _todoElDia = false;

  Color _color = Colors.blue;

  List<Meeting> _eventos = [];

  late MeetingDataSource _meetingDataSource;

  @override
  void initState() {
    super.initState();

    _meetingDataSource = MeetingDataSource(_eventos);

    _leeBase();
  }

  @override
  void dispose() {
    _nombreEvento.dispose();
    super.dispose();
  }

  void _aniadirEvento() {
    _nombreEvento.clear();

    _fechaInicio = DateTime.now();

    _fechaFin = DateTime.now().add(const Duration(hours: 1));

    _todoElDia = false;

    _color = Colors.blue;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Añadir evento",
                        style: TextStyle(fontSize: 25),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: _nombreEvento,
                        decoration: const InputDecoration(
                          labelText: "Nombre evento",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: MaterialButton(
                              color: Colors.blue,
                              child: Text(
                                "Inicio: ${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year} - ${_fechaInicio.hour}:${_fechaInicio.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                final fecha = await showDatePicker(
                                  context: context,
                                  initialDate: _fechaInicio,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );

                                if (fecha != null) {
                                  final hora = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(
                                      _fechaInicio,
                                    ),
                                  );

                                  if (hora != null) {
                                    setStateDialog(() {
                                      _fechaInicio = DateTime(
                                        fecha.year,
                                        fecha.month,
                                        fecha.day,
                                        hora.hour,
                                        hora.minute,
                                      );
                                    });
                                  }
                                }
                              },
                            ),
                          ),

                          const SizedBox(width: 10),

                          Flexible(
                            child: MaterialButton(
                              color: Colors.blue,
                              child: Text(
                                "Fin: ${_fechaFin.day}/${_fechaFin.month}/${_fechaFin.year} - ${_fechaFin.hour}:${_fechaFin.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                final fecha = await showDatePicker(
                                  context: context,
                                  initialDate: _fechaFin,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );

                                if (fecha != null) {
                                  final hora = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(
                                      _fechaFin,
                                    ),
                                  );

                                  if (hora != null) {
                                    setStateDialog(() {
                                      _fechaFin = DateTime(
                                        fecha.year,
                                        fecha.month,
                                        fecha.day,
                                        hora.hour,
                                        hora.minute,
                                      );
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      MaterialButton(
                        color: _color,
                        child: const Text(
                          "Seleccionar color",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          Color colorTemporal = _color;

                          await showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: const Text("Selecciona color"),
                                content: BlockPicker(
                                  pickerColor: _color,
                                  onColorChanged: (color) {
                                    colorTemporal = color;
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Aceptar"),
                                  ),
                                ],
                              );
                            },
                          );

                          setStateDialog(() {
                            _color = colorTemporal;
                          });
                        },
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Todo el día"),
                          Checkbox(
                            value: _todoElDia,
                            onChanged: (value) {
                              setStateDialog(() {
                                _todoElDia = value ?? false;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MaterialButton(
                            color: Colors.red,
                            child: const Text(
                              "Cancelar",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),

                          const SizedBox(width: 10),

                          MaterialButton(
                            color: Colors.green,
                            child: const Text(
                              "Guardar",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              if (_nombreEvento.text.trim().isEmpty) {
                                return;
                              }

                              final evento = {
                                "Nombre": _nombreEvento.text.trim(),
                                "FechaInicio": _fechaInicio,
                                "FechaFin": _fechaFin,
                                "Color": _color.value,
                                "TodoElDia": _todoElDia,
                              };

                              Navigator.pop(dialogContext);
                              await _escribirEventoNube(evento);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _leeBase() async {
    try {
      QuerySnapshot<Map<String, dynamic>> docs = await db
          .collection("eventos")
          .get();

      _eventos.clear();

      for (int i = 0; i < docs.size; i++) {
        _eventos.add(
          Meeting(
            docs.docs[i].get("Nombre"),
            (docs.docs[i].get("FechaInicio") as Timestamp).toDate(),
            (docs.docs[i].get("FechaFin") as Timestamp).toDate(),
            Color(docs.docs[i].get("Color")),
            docs.docs[i].get("TodoElDia"),
          ),
        );
      }

      _meetingDataSource.appointments = _eventos;

      _meetingDataSource.notifyListeners(
        CalendarDataSourceAction.reset,
        _eventos,
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Error leyendo eventos: $e");
    }
  }

  Future<void> _escribirEventoNube(Map<String, dynamic> evento) async {
    try {
      await db.collection("eventos").add({
        "Nombre": evento["Nombre"],
        "FechaInicio": Timestamp.fromDate(evento["FechaInicio"]),
        "FechaFin": Timestamp.fromDate(evento["FechaFin"]),
        "Color": evento["Color"],
        "TodoElDia": evento["TodoElDia"],
      });

      final nuevoEvento = Meeting(
        evento["Nombre"],
        evento["FechaInicio"],
        evento["FechaFin"],
        Color(evento["Color"]),
        evento["TodoElDia"],
      );

      _eventos.add(nuevoEvento);

      _meetingDataSource.appointments!.add(nuevoEvento);

      _meetingDataSource.notifyListeners(CalendarDataSourceAction.add, [
        nuevoEvento,
      ]);

      if (mounted) {
        setState(() {});
      }

      print("Evento guardado correctamente");
    } catch (e) {
      print("Error escribiendo evento: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SfCalendar(
        view: CalendarView.month,
        dataSource: _meetingDataSource,
        monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
          showAgenda: true,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _aniadirEvento,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];

    if (meeting is Meeting) {
      return meeting;
    }

    throw Exception("Tipo inválido");
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;

  DateTime from;

  DateTime to;

  Color background;

  bool isAllDay;
}