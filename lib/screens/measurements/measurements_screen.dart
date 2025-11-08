import 'package:flutter/material.dart';
import 'package:ring_sizer/services/measurement_service.dart';

class MeasurementsScreen extends StatefulWidget {
  @override
  _MeasurementsScreenState createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final MeasurementService _measurementService = MeasurementService();

  String _selectedType = 'bague';
  int? _calculatedSize;
  bool _isLoading = false;

  void _calculate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _calculatedSize = null; });

    try {
      final size = await _measurementService.calculateStandardSize(
        _selectedType,
        double.parse(_valueController.text),
      );
      setState(() { _calculatedSize = size; });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() { _isLoading = false; });
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });

    try {
      await _measurementService.saveMeasurement(
        _selectedType,
        double.parse(_valueController.text),
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mesure enregistrée !')));
      Navigator.of(context).pop(); // Revenir à l'écran de profil
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calcul de Taille')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(labelText: 'Circonférence (mm)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Veuillez entrer une valeur';
                  if (double.tryParse(value) == null) return 'Veuillez entrer un nombre valide';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'bague', label: Text('Bague')),
                  ButtonSegment(value: 'bracelet', label: Text('Bracelet')),
                ],
                selected: {_selectedType},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                ElevatedButton(onPressed: _calculate, child: const Text('Calculer la taille')),
                ElevatedButton(onPressed: _save, child: const Text('Enregistrer la mesure')),
              ],
              if (_calculatedSize != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'Taille standard calculée : $_calculatedSize',
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
