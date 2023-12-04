import 'dart:io';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class Formulario extends StatefulWidget {
  const Formulario({super.key});

  @override
  State<StatefulWidget> createState() {
    return FormularioState();
  }
}

class FormularioState extends State<Formulario> {
  TextEditingController nameController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  dynamic avatar;
  dynamic city;
  dynamic gender;
  dynamic age;
  dynamic web;
  dynamic mobile;

  Future<Iterable<Map<String, Object?>>> _loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getKeys().map((key) => {key: prefs.get(key)});
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> sendToEmail(String email) async {
    final mailBody = {
      "name": nameController.text,
      "about": aboutController.text,
      "phone": phoneController.text,
      "email": emailController.text,
      "city": city,
      "gender": gender,
      "age": age,
      "web_dev?": web,
      "mobile_dev?": mobile
    };
    final Uri mailUrl = Uri.parse(
        "mailto:$email?subject=Seus dados vindos do app&body=${Uri.encodeComponent(mailBody.toString())}");

    try {
      await launchUrl(mailUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      throw 'Não foi possível abrir o app de email $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(30),
            child: SingleChildScrollView(
                child: FutureBuilder(
              future: _loadData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  print(snapshot.error.toString());
                }

                if (snapshot.hasData) {
                  dynamic findInSp(String key) {
                    return snapshot.data!
                        .firstWhere((element) => element.containsKey(key),
                            orElse: () => {})
                        .values
                        .firstOrNull;
                  }

                  avatar = findInSp('avatar');
                  city = findInSp('city') ?? 'Londrina';
                  gender = findInSp('gender') ?? '';
                  age = findInSp('age') ?? 0.0;
                  web = findInSp('web') ?? false;
                  mobile = findInSp('mobile') ?? false;

                  nameController.text = findInSp('name') ?? '';
                  aboutController.text = findInSp('about') ?? '';
                  phoneController.text = findInSp('phone') ?? '';
                  emailController.text = findInSp('email') ?? '';
                }

                return Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20, top: 20),
                    child: ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (modalContext) {
                                return SizedBox(
                                  height: 100,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          child: const Text('Câmera'),
                                          onPressed: () async {
                                            final SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();

                                            final ImagePicker picker =
                                                ImagePicker();
                                            final XFile? photo =
                                                await picker.pickImage(
                                                    source: ImageSource.camera);

                                            final String imagePath =
                                                photo!.path;

                                            await prefs.setString(
                                                'avatar', imagePath);

                                            Navigator.pop(modalContext);

                                            setState(() {});
                                          },
                                        ),
                                        ElevatedButton(
                                          child: const Text('Galeria'),
                                          onPressed: () async {
                                            final SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();

                                            final ImagePicker picker =
                                                ImagePicker();

                                            final XFile? image =
                                                await picker.pickImage(
                                                    source:
                                                        ImageSource.gallery);

                                            final String imagePath =
                                                image!.path;

                                            await prefs.setString(
                                                'avatar', imagePath);

                                            Navigator.pop(modalContext);

                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              isDismissible: true);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.grey[400],
                          foregroundColor: Colors.grey,
                        ),
                        child: CircleAvatar(
                            backgroundColor: Colors.grey[400],
                            minRadius: 50,
                            child: ClipOval(
                              child: avatar != null
                                  ? Image.file(
                                      File(avatar),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.fill,
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                            ))),
                  ),
                  TextField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                        hintText: "Seu nome", prefixIcon: Icon(Icons.person)),
                    onSubmitted: (value) async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      await prefs.setString('name', value);
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: aboutController,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.article),
                        hintText: "Sobre você",
                        border: OutlineInputBorder()),
                    onChanged: (value) async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      await prefs.setString('about', value);
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone),
                        hintText: "Telefone",
                        border: OutlineInputBorder()),
                    onChanged: (value) async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      await prefs.setString('phone', value);
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        hintText: "E-mail",
                        border: OutlineInputBorder()),
                    onChanged: (value) async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      await prefs.setString('email', value);
                    },
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Cidade",
                          prefixIcon: Icon(Icons.location_city)),
                      items: const [
                        DropdownMenuItem(
                            value: "Londrina", child: Text("Londrina-PR")),
                        DropdownMenuItem(
                            value: "Cambé", child: Text("Cambé-PR")),
                        DropdownMenuItem(
                            value: "Rolândia", child: Text("Rolândia-PR"))
                      ],
                      value: city,
                      onChanged: (value) async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                        await prefs.setString('city', (value as String));
                      }),
                  const SizedBox(height: 15),
                  Column(children: [
                    ListTile(
                        title: const Text("Masculino"),
                        leading: Radio(
                            value: 'M',
                            groupValue: gender,
                            onChanged: (value) async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();

                              await prefs.setString(
                                  'gender', (value as String));

                              setState(() {});
                            })),
                    ListTile(
                        title: const Text("Feminino"),
                        leading: Radio(
                            value: 'F',
                            groupValue: gender,
                            onChanged: (value) async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();

                              await prefs.setString(
                                  'gender', (value as String));

                              setState(() {});
                            }))
                  ]),
                  const Divider(),
                  Column(children: [
                    ListTile(
                        title: const Text("Desenvolvimento web"),
                        leading: Checkbox(
                            value: web,
                            onChanged: (value) async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();

                              await prefs.setBool('web', value!);

                              setState(() {});
                            })),
                    ListTile(
                      title: const Text("Desenvolvimento mobile"),
                      leading: Checkbox(
                        value: mobile,
                        onChanged: (value) async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();

                          await prefs.setBool('mobile', value!);

                          setState(() {});
                        },
                      ),
                    )
                  ]),
                  const Divider(),
                  Slider(
                    value: age,
                    min: 0,
                    max: 120,
                    divisions: 120,
                    label: "Idade $age",
                    onChangeEnd: (value) async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      await prefs.setDouble('age', value);

                      setState(() {});
                    },
                    onChanged: (value) {},
                  ),
                  const Divider(),
                  FilledButton(
                      onPressed: emailController.text.isEmpty
                          ? null
                          : () async {
                              await sendToEmail(emailController.text);
                            },
                      child: const Text('Enviar para o email'))
                ]);
              },
            ))));
  }
}
