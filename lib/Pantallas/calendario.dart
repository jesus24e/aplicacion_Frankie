import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import "package:syncfusion_flutter_calendar/calendar.dart";
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // añadir en pubspec.yaml

class calendar extends StatefulWidget {
  const calendar({super.key, required this.titulo});

  final String titulo;

  @override
  State<calendar> createState() => _calendarState();
}

class _calendarState extends State<calendar> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final TextEditingController _nombreEvento = TextEditingController();
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now();
  bool _todoElDia = false;
  Color _color = Colors.blue;

  final List<Map> _eventos = [];

  void _aniadirEvento() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              elevation: 50,
              backgroundColor: Colors.white,
              shadowColor: Colors.pink,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Añadir evento:", style: TextStyle(fontSize: 30)),
                    SizedBox(height: 5),

                    SizedBox(
                      width: 300,
                      child: TextField(
                        decoration: InputDecoration(labelText: "Nombre evento"),
                        controller: _nombreEvento,
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                    SizedBox(height: 5),

                    // --- Punto 1: Botones de fecha inicio y fin ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          color: Colors.blue,
                          child: Text(
                            "Fecha inicio: ${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year} - ${_fechaInicio.hour}:${_fechaInicio.minute}",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            DateTime? inicio =
                                await showDatePicker(
                                  context: context,
                                  initialDate: _fechaInicio,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                ).then((inicio) async {
                                  if (inicio != null) {
                                    await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then((hora) {
                                      if (hora != null) {
                                        setStateDialog(() {
                                          _fechaInicio = inicio.add(
                                            Duration(
                                              hours: hora.hour,
                                              minutes: hora.minute,
                                            ),
                                          );
                                        });
                                      }
                                    });
                                  }
                                });
                          },
                        ),
                        SizedBox(width: 10),
                        MaterialButton(
                          color: Colors.blue,
                          child: Text(
                            "Fecha fin: ${_fechaFin.day}/${_fechaFin.month}/${_fechaFin.year} - ${_fechaFin.hour}:${_fechaFin.minute}",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            DateTime? fin =
                                await showDatePicker(
                                  context: context,
                                  initialDate: _fechaFin,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                ).then((fin) async {
                                  if (fin != null) {
                                    await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then((hora) {
                                      if (hora != null) {
                                        setStateDialog(() {
                                          _fechaFin = fin.add(
                                            Duration(
                                              hours: hora.hour,
                                              minutes: hora.minute,
                                            ),
                                          );
                                        });
                                      }
                                    });
                                  }
                                });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 5),

                    // --- Punto 2: Botón color picker ---
                    MaterialButton(
                      color: _color,
                      child: Text(
                        "Seleccionar color",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Elige un color"),
                              content: BlockPicker(
                                pickerColor: _color,
                                onColorChanged: (color) {
                                  setStateDialog(() {
                                    _color = color;
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 5),

                    // --- Punto 3: Checkbox con setStateDialog ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Es todo el dia: "),
                        SizedBox(height: 5),
                        Checkbox(
                          value: _todoElDia,
                          onChanged: (value) {
                            setStateDialog(() {
                              _todoElDia = !_todoElDia;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    MaterialButton(
                      onPressed: () {
                        Map<String, dynamic> evento = {};
                        evento["Nombre"] = _nombreEvento.text;
                        evento["TodoElDia"] = _todoElDia;
                        evento["FechaInicio"] = _fechaInicio;
                        evento["FechaFin"] = _fechaFin;
                        evento["Color"] = _color.value;

                        _escribirEventoNube(evento);
                      },
                      color: Colors.green,
                      child: Text("Guardar"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _leeBase() async {
    QuerySnapshot<Map<String, dynamic>> docs = await db
        .collection("eventos")
        .get();
    for (int i = 0; i < docs.size; i++) {
      Map<String, dynamic> aux = {};
      aux["Nombre"] = docs.docs[i].get("Nombre");
      aux["FechaInicio"] = docs.docs[i].get("FechaInicio").toDate();
      aux["FechaFin"] = docs.docs[i].get("FechaFin").toDate();
      aux["Color"] = Color(docs.docs[i].get("Color"));
      aux["TodoElDia"] = docs.docs[i].get("TodoElDia");

      setState(() {
        _eventos.add(aux);
      });
    }
  }

  void _escribirEventoNube(Map<String, dynamic> evento) async {
    try {
      await db.collection("eventos").doc(evento["Nombre"]).set({
        "Nombre": evento["Nombre"],
        "FechaInicio": Timestamp.fromDate(evento["FechaInicio"]),
        "FechaFin": Timestamp.fromDate(evento["FechaFin"]),
        "Color": evento["Color"],
        "TodoElDia": evento["TodoElDia"],
      });

      print("Evento guardado correctamente");
    } catch (e) {
      print("Error al escribir evento: $e");
    }
  }

  @override
  void initState() {
    _leeBase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCalendar(
        view: CalendarView.month,
        dataSource: MeetingDataSource(_getDataSource(_eventos)),
        monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
          showAgenda: true,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _aniadirEvento();
        },
        tooltip: "añadir evento",
        child: Icon(Icons.add),
      ),
    );
  }

  List<Meeting> _getDataSource(List<Map> eventos) {
    final List<Meeting> meetings = <Meeting>[];
    for (var i = 0; i < eventos.length; i++) {
      meetings.add(
        Meeting(
          eventos[i]["Nombre"],
          eventos[i]["FechaInicio"],
          eventos[i]["FechaFin"],
          eventos[i]["Color"],
          eventos[i]["TodoElDia"],
        ),
      );
    }
    return meetings;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
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

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }
    return meetingData;
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
