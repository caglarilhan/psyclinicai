import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/pseudonym_service.dart';
import '../../services/secure_fields_service.dart';
import '../../services/patient_service.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
// Web'de gerçek dart:html, diğer platformlarda stub
import '../../utils/html_stub.dart' if (dart.library.html) 'dart:html' as html;
import 'package:share_plus/share_plus.dart';
import '../../services/patient_service.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final List<Patient> _patients = [
    Patient(
      id: '1',
      firstName: 'Ahmet',
      lastName: 'Yılmaz',
      email: 'ahmet.yilmaz@email.com',
      phone: '+90 555 123 4567',
      birthDate: DateTime(1985, 3, 15),
      gender: 'Erkek',
      primaryDiagnosis: 'Depresyon',
      status: PatientStatus.active,
      riskLevel: RiskLevel.medium,
      firstSessionDate: DateTime(2024, 1, 15),
      totalSessions: 8,
      lastSessionDate: DateTime(2024, 2, 10),
    ),
    Patient(
      id: '2',
      firstName: 'Ayşe',
      lastName: 'Demir',
      email: 'ayse.demir@email.com',
      phone: '+90 555 987 6543',
      birthDate: DateTime(1990, 7, 22),
      gender: 'Kadın',
      primaryDiagnosis: 'Anksiyete Bozukluğu',
      status: PatientStatus.active,
      riskLevel: RiskLevel.low,
      firstSessionDate: DateTime(2024, 1, 10),
      totalSessions: 12,
      lastSessionDate: DateTime(2024, 2, 8),
    ),
    Patient(
      id: '3',
      firstName: 'Mehmet',
      lastName: 'Kaya',
      email: 'mehmet.kaya@email.com',
      phone: '+90 555 456 7890',
      birthDate: DateTime(1978, 11, 8),
      gender: 'Erkek',
      primaryDiagnosis: 'PTSD',
      status: PatientStatus.inactive,
      riskLevel: RiskLevel.high,
      firstSessionDate: DateTime(2023, 12, 1),
      totalSessions: 15,
      lastSessionDate: DateTime(2024, 1, 20),
    ),
  ];

  String _searchQuery = '';
  PatientStatus? _selectedStatus;
  RiskLevel? _selectedRiskLevel;

  @override
  Widget build(BuildContext context) {
    final filteredPatients = _patients.where((patient) {
      final matchesSearch = patient.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          patient.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          patient.phone.contains(_searchQuery);
      final matchesStatus = _selectedStatus == null || patient.status == _selectedStatus;
      final matchesRisk = _selectedRiskLevel == null || patient.riskLevel == _selectedRiskLevel;
      return matchesSearch && matchesStatus && matchesRisk;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasta Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddPatientDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Hasta ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // İstatistikler
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Toplam', '${_patients.length}', Icons.people),
                _buildStatCard('Aktif', '${_patients.where((p) => p.status == PatientStatus.active).length}', Icons.check_circle),
                _buildStatCard('Yüksek Risk', '${_patients.where((p) => p.riskLevel == RiskLevel.high).length}', Icons.warning),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Hasta listesi
          Expanded(
            child: ListView.builder(
              itemCount: filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = filteredPatients[index];
                return _buildPatientCard(patient);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildPatientCard(Patient patient) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(patient.status),
          child: Text(
            patient.initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          patient.fullName + '  ·  ' + PseudonymService.generate(patient.id),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(patient.primaryDiagnosis),
            Text('${patient.totalSessions} seans • ${patient.age} yaş'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRiskBadge(patient.riskLevel),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) => _handlePatientAction(value, patient),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: ListTile(
                    leading: Icon(Icons.visibility),
                    title: Text('Görüntüle'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Düzenle'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'session',
                  child: ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('Seans Ekle'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'notes',
                  child: ListTile(
                    leading: Icon(Icons.note),
                    title: Text('Notlar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _showPatientDetails(patient),
      ),
    );
  }

  Widget _buildRiskBadge(RiskLevel riskLevel) {
    Color color;
    String text;
    
    switch (riskLevel) {
      case RiskLevel.low:
        color = Colors.green;
        text = 'Düşük';
        break;
      case RiskLevel.medium:
        color = Colors.orange;
        text = 'Orta';
        break;
      case RiskLevel.high:
        color = Colors.red;
        text = 'Yüksek';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(PatientStatus status) {
    switch (status) {
      case PatientStatus.active:
        return Colors.green;
      case PatientStatus.inactive:
        return Colors.grey;
      case PatientStatus.discharged:
        return Colors.blue;
    }
  }

  void _showAddPatientDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Hasta Ekle'),
        content: _AddPatientForm(onSaved: (name, email, phone, birthDate, gender, notes, kvkk){
          final id = DateTime.now().millisecondsSinceEpoch.toString();
          // PII alanlarını şifrele
          if (email != null && email.isNotEmpty) {
            SecureFieldsService.encryptAndStore(PIIFieldHelper.getFieldName(PIIFieldType.email) + '_' + id, email);
          }
          if (phone != null && phone.isNotEmpty) {
            SecureFieldsService.encryptAndStore(PIIFieldHelper.getFieldName(PIIFieldType.phone) + '_' + id, phone);
          }
          context.read<PatientService>().addPatient(PatientItem(id: id, name: name, email: null, phone: null));
          setState((){
            _patients.add(Patient(
              id: id,
              firstName: name.split(' ').first,
              lastName: name.split(' ').length>1? name.split(' ').sublist(1).join(' ') : '',
              email: email != null && email.isNotEmpty ? _mask(email) : '',
              phone: phone != null && phone.isNotEmpty ? _mask(phone) : '',
              birthDate: birthDate ?? DateTime(1990,1,1),
              gender: gender ?? '-',
              primaryDiagnosis: notes?.trim().isNotEmpty == true ? notes!.trim() : '-',
              status: PatientStatus.active,
              riskLevel: RiskLevel.low,
              firstSessionDate: DateTime.now(),
              totalSessions: 0,
            ));
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hasta eklendi')),);
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtreler'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<PatientStatus?>(
              decoration: const InputDecoration(labelText: 'Durum'),
              value: _selectedStatus,
              items: [
                const DropdownMenuItem(value: null, child: Text('Tümü')),
                const DropdownMenuItem(value: PatientStatus.active, child: Text('Aktif')),
                const DropdownMenuItem(value: PatientStatus.inactive, child: Text('Pasif')),
                const DropdownMenuItem(value: PatientStatus.discharged, child: Text('Taburcu')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RiskLevel?>(
              decoration: const InputDecoration(labelText: 'Risk Seviyesi'),
              value: _selectedRiskLevel,
              items: [
                const DropdownMenuItem(value: null, child: Text('Tümü')),
                const DropdownMenuItem(value: RiskLevel.low, child: Text('Düşük')),
                const DropdownMenuItem(value: RiskLevel.medium, child: Text('Orta')),
                const DropdownMenuItem(value: RiskLevel.high, child: Text('Yüksek')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRiskLevel = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStatus = null;
                _selectedRiskLevel = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Temizle'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
  }

  void _showPatientDetails(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(patient.fullName),
        content: DefaultTabController(
          length: 2,
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TabBar(tabs: [Tab(text: 'Özet'), Tab(text: 'Belgeler')]),
                SizedBox(
                  height: 320,
                  child: TabBarView(children: [
                    // Özet
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('E-posta', patient.email),
                          _buildDetailRow('Telefon', patient.phone),
                          _buildDetailRow('Yaş', '${patient.age}'),
                          _buildDetailRow('Cinsiyet', patient.gender),
                          _buildDetailRow('Tanı', patient.primaryDiagnosis),
                          _buildDetailRow('Durum', patient.status.name),
                          _buildDetailRow('Risk Seviyesi', patient.riskLevel.name),
                          _buildDetailRow('Toplam Seans', '${patient.totalSessions}'),
                          _buildDetailRow('İlk Seans', DateFormat('dd.MM.yyyy').format(patient.firstSessionDate)),
                          if (patient.lastSessionDate != null)
                            _buildDetailRow('Son Seans', DateFormat('dd.MM.yyyy').format(patient.lastSessionDate!)),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final email = await SecureFieldsService.decryptAndRetrieve(PIIFieldHelper.getFieldName(PIIFieldType.email) + '_' + patient.id);
                              final phone = await SecureFieldsService.decryptAndRetrieve(PIIFieldHelper.getFieldName(PIIFieldType.phone) + '_' + patient.id);
                              if (!context.mounted) return;
                              showDialog(context: context, builder: (ctx)=> AlertDialog(
                                title: const Text('Gizli Bilgiler'),
                                content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  _buildDetailRow('E-posta (orijinal)', email ?? '—'),
                                  _buildDetailRow('Telefon (orijinal)', phone ?? '—'),
                                ]),
                                actions: [TextButton(onPressed: ()=> Navigator.pop(ctx), child: const Text('Kapat'))],
                              ));
                            },
                            icon: const Icon(Icons.lock_open),
                            label: const Text('Gizli Bilgileri Göster'),
                          ),
                        ],
                      ),
                    ),
                    // Belgeler
                    Builder(builder: (ctx){
                      final docs = context.read<PatientService>().getDocs(patient.id);
                      if (docs.isEmpty) return const Center(child: Text('Belge yok'));
                      final TextEditingController _q = TextEditingController();
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                            child: TextField(
                              controller: _q,
                              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Belge ara...'),
                              onChanged: (_) { (ctx as Element).markNeedsBuild(); },
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Wrap(spacing: 8, children: [
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final pdf = pw.Document();
                                  pdf.addPage(pw.Page(
                                    pageFormat: PdfPageFormat.a4,
                                    build: (c)=> pw.Center(child: pw.Text('Demo PDF Belgesi')),
                                  ));
                                  final bytes = await pdf.save();
                                  await context.read<PatientService>().addDoc(PatientDoc(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    patientId: patient.id,
                                    name: 'Demo_Belge.pdf',
                                    mimeType: 'application/pdf',
                                    createdAt: DateTime.now(),
                                    data: bytes,
                                  ));
                                  if (mounted) setState((){});
                                },
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text('Yeni Belge (PDF)')
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  await context.read<PatientService>().addDoc(PatientDoc(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    patientId: patient.id,
                                    name: 'Demo_Gorsel.png',
                                    mimeType: 'image/png',
                                    createdAt: DateTime.now(),
                                    data: Uint8List(0),
                                  ));
                                  if (mounted) setState((){});
                                },
                                icon: const Icon(Icons.image),
                                label: const Text('Yeni Belge (Görsel)')
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final content = 'Demo TXT Notu\nTarih: ' + DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now()) + '\n\nKısa örnek metin içeriği.';
                                  await context.read<PatientService>().addDoc(PatientDoc(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    patientId: patient.id,
                                    name: 'Demo_Not.txt',
                                    mimeType: 'text/plain',
                                    createdAt: DateTime.now(),
                                    data: utf8.encode(content),
                                  ));
                                  if (mounted) setState((){});
                                },
                                icon: const Icon(Icons.description_outlined),
                                label: const Text('Yeni Belge (TXT)')
                              ),
                            ]),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.separated(
                              itemCount: docs.where((d)=> _q.text.trim().isEmpty || d.name.toLowerCase().contains(_q.text.toLowerCase())).length,
                              separatorBuilder: (_, __)=> const Divider(),
                              itemBuilder: (_, i){
                                final filtered = docs.where((d)=> _q.text.trim().isEmpty || d.name.toLowerCase().contains(_q.text.toLowerCase())).toList();
                                final d = filtered[i];
                                return ListTile(
                            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                            title: Text(d.name),
                            subtitle: Text(DateFormat('dd.MM.yyyy HH:mm').format(d.createdAt)),
                                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                    // İndir/Paylaş
                                    IconButton(icon: const Icon(Icons.download), onPressed: () async {
                                      final bytes = Uint8List.fromList(d.data);
                                      if (kIsWeb) {
                                        final blob = html.Blob([bytes], d.mimeType);
                                        final url = html.Url.createObjectUrlFromBlob(blob);
                                        final a = html.AnchorElement(href: url)..setAttribute('download', d.name)..click();
                                        html.Url.revokeObjectUrl(url);
                                      } else {
                                        final file = XFile.fromData(bytes, name: d.name, mimeType: d.mimeType);
                                        await Share.shareXFiles([file]);
                                      }
                                    }),
                                    if (d.mimeType == 'application/pdf')
                                      IconButton(icon: const Icon(Icons.print), onPressed: (){ Printing.layoutPdf(onLayout: (format) async => Uint8List.fromList(d.data)); }),
                                    IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async {
                                      await context.read<PatientService>().deleteDoc(patient.id, d.id);
                                      if (mounted) setState((){});
                                    }),
                                  ]),
                            onTap: () async {
                              if (d.mimeType.startsWith('application/pdf')) {
                                await Printing.layoutPdf(onLayout: (format) async => Uint8List.fromList(d.data));
                              } else if (d.mimeType.startsWith('image/')) {
                                showDialog(context: context, builder: (c)=> AlertDialog(
                                  content: d.data.isEmpty ? const Text('Demo görsel yakında') : Image.memory(Uint8List.fromList(d.data)),
                                  actions: [TextButton(onPressed: ()=> Navigator.pop(c), child: const Text('Kapat'))],
                                ));
                                    } else if (d.mimeType.startsWith('text/')) {
                                      showDialog(context: context, builder: (c)=> AlertDialog(
                                        title: Text(d.name),
                                        content: SingleChildScrollView(child: Text(String.fromCharCodes(d.data))),
                                        actions: [TextButton(onPressed: ()=> Navigator.pop(c), child: const Text('Kapat'))],
                                      ));
                              } else {
                                showDialog(context: context, builder: (c)=> AlertDialog(
                                  title: Text(d.name),
                                  content: const Text('Önizleme desteklenmiyor (demo).'),
                                  actions: [TextButton(onPressed: ()=> Navigator.pop(c), child: const Text('Kapat'))],
                                ));
                              }
                            },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }),
                  ]),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handlePatientAction('edit', patient);
            },
            child: const Text('Düzenle'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _mask(String v){
    if(v.contains('@')){ // email mask
      final parts = v.split('@');
      final name = parts[0];
      final domain = parts[1];
      final maskedName = name.length<=2 ? name[0] + '*' : name.substring(0,2) + '*' * (name.length-2);
      return maskedName + '@' + domain;
    }
    // phone mask
    return v.length < 4 ? '***' : v.substring(0, v.length-4).replaceAll(RegExp(r'\d'), '*') + v.substring(v.length-4);
  }

  void _handlePatientAction(String action, Patient patient) {
    switch (action) {
      case 'view':
        _showPatientDetails(patient);
        break;
      case 'edit':
        _showEditPatientDialog(patient);
        break;
      case 'session':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${patient.fullName} için seans ekleme özelliği yakında eklenecek')),
        );
        break;
      case 'notes':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${patient.fullName} notları yakında eklenecek')),
        );
        break;
    }
  }

  void _showEditPatientDialog(Patient p){
    final nameCtrl = TextEditingController(text: p.fullName);
    final notesCtrl = TextEditingController(text: p.primaryDiagnosis == '-' ? '' : p.primaryDiagnosis);
    showDialog(
      context: context,
      builder: (context)=> AlertDialog(
        title: const Text('Hasta Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Ad Soyad')),
            const SizedBox(height: 8),
            TextField(controller: notesCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Not/Özet (opsiyonel)')),
          ],
        ),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(onPressed: (){
            final parts = nameCtrl.text.trim().split(' ');
            final first = parts.isNotEmpty? parts.first : p.firstName;
            final last = parts.length>1? parts.sublist(1).join(' ') : p.lastName;
            setState((){
              final idx = _patients.indexWhere((x)=> x.id == p.id);
              if(idx>=0){
                _patients[idx] = Patient(
                  id: p.id,
                  firstName: first,
                  lastName: last,
                  email: p.email,
                  phone: p.phone,
                  birthDate: p.birthDate,
                  gender: p.gender,
                  primaryDiagnosis: notesCtrl.text.trim().isEmpty? '-' : notesCtrl.text.trim(),
                  status: p.status,
                  riskLevel: p.riskLevel,
                  firstSessionDate: p.firstSessionDate,
                  totalSessions: p.totalSessions,
                  lastSessionDate: p.lastSessionDate,
                );
              }
            });
            // PatientService adını da güncelle
            final svc = context.read<PatientService>();
            final item = svc.getById(p.id);
            if(item!=null){ svc.addPatient(PatientItem(id: item.id, name: first + ' ' + last, email: item.email, phone: item.phone)); }
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hasta güncellendi')));
          }, child: const Text('Kaydet')),
        ],
      ),
    );
  }
}

// Hasta modeli
class Patient {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime birthDate;
  final String gender;
  final String primaryDiagnosis;
  final PatientStatus status;
  final RiskLevel riskLevel;
  final DateTime firstSessionDate;
  final int totalSessions;
  final DateTime? lastSessionDate;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.gender,
    required this.primaryDiagnosis,
    required this.status,
    required this.riskLevel,
    required this.firstSessionDate,
    required this.totalSessions,
    this.lastSessionDate,
  });

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}';
  int get age => DateTime.now().year - birthDate.year;
}

enum PatientStatus {
  active,
  inactive,
  discharged,
}

enum RiskLevel {
  low,
  medium,
  high,
}

class _AddPatientForm extends StatefulWidget {
  final void Function(String name, String? email, String? phone, DateTime? birthDate, String? gender, String? notes, bool kvkk) onSaved;
  const _AddPatientForm({required this.onSaved});
  @override
  State<_AddPatientForm> createState() => _AddPatientFormState();
}

class _AddPatientFormState extends State<_AddPatientForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  DateTime? _birthDate;
  String? _gender;
  bool _kvkk = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Ad Soyad'),
            validator: (v)=> (v==null||v.trim().length<2)? 'Ad soyad giriniz' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'E-posta (opsiyonel)'),
            validator: (v){
              if(v==null||v.isEmpty) return null;
              final emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              return emailRe.hasMatch(v.trim())? null : 'Geçerli e-posta girin';
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phone,
            decoration: const InputDecoration(labelText: 'Telefon (opsiyonel)'),
            keyboardType: TextInputType.phone,
            validator: (v){
              if(v==null||v.isEmpty) return null;
              final phoneRe = RegExp(r'^\+?[0-9\s]{7,15}$');
              return phoneRe.hasMatch(v.trim())? null : 'Geçerli telefon girin';
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Doğum Tarihi (opsiyonel)', border: OutlineInputBorder()),
                  child: InkWell(
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(context: context, initialDate: DateTime(now.year-25, now.month, now.day), firstDate: DateTime(1900,1,1), lastDate: now);
                      if(picked!=null){ setState(()=> _birthDate = picked); }
                    },
                    child: Text(_birthDate==null? 'Seç' : DateFormat('dd.MM.yyyy').format(_birthDate!)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(labelText: 'Cinsiyet (opsiyonel)'),
                  items: const [
                    DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                    DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
                    DropdownMenuItem(value: '-', child: Text('Diğer/Belirtmek istemiyorum')),
                  ],
                  onChanged: (v)=> setState(()=> _gender = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Notlar (opsiyonel)'),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _kvkk,
            onChanged: (v)=> setState(()=> _kvkk = v ?? false),
            title: const Text('KVKK aydınlatma metni okundu ve onaylandı'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: (){
                if(!_kvkk){
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen KVKK onayını işaretleyin')));
                  return;
                }
                if(_formKey.currentState!.validate()){
                  widget.onSaved(
                    _name.text.trim(),
                    _email.text.trim().isEmpty? null : _email.text.trim(),
                    _phone.text.trim().isEmpty? null : _phone.text.trim(),
                    _birthDate,
                    _gender,
                    _notes.text.trim().isEmpty? null : _notes.text.trim(),
                    _kvkk,
                  );
                }
              },
              child: const Text('Kaydet'),
            ),
          )
        ],
      ),
    );
  }
}
