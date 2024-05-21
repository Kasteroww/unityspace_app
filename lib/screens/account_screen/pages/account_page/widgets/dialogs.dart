import 'package:flutter/material.dart';
import 'package:unityspace/screens/account_screen/pages/account_page/account_page.dart';
import 'package:unityspace/screens/widgets/common/paddings.dart';
import 'package:unityspace/utils/theme.dart';

class ChangeEmailDialog extends StatelessWidget {
  const ChangeEmailDialog({
    super.key,
    required this.oldEmail,
    required this.store,
  });

  final String oldEmail;
  final AccountPageStore store;

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: oldEmail);
    return Dialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: 300,
        height: 200,
        child: PaddingAll(
          16,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Изменить Email',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                  CloseButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const PaddingTop(8),
              const Text('Введите новый Email'),
              const PaddingTop(8),
              TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: ColorConstants.grey03))),
              ),
              const PaddingTop(8),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: FilledButton(
                    onPressed: () async {
                      await store.changeUserEmail(controller.text.trim());
                      Navigator.of(context).pop();
                      showDialog(
                          context: context,
                          builder: (context) {
                            return ConfirmEmailDialog(
                              email: controller.text,
                              store: store,
                            );
                          });
                    },
                    child: const Text('Сохранить')),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ConfirmEmailDialog extends StatelessWidget {
  const ConfirmEmailDialog({
    super.key,
    required this.email,
    required this.store,
  });

  final String email;
  final AccountPageStore store;

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return Dialog(
      child: SizedBox(
        width: 300,
        height: 400,
        child: PaddingAll(
          16,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 150,
                    child: Text(
                      'Подтвердить электронную почту',
                      maxLines: 2,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  CloseButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const PaddingTop(16),
              RichText(
                  text: TextSpan(
                      text:
                          'Текстовое сообщение с кодом проверки отправлено на ',
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                    TextSpan(
                        text: email,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontWeight: FontWeight.w500))
                  ])),
              const PaddingTop(16),
              SizedBox(
                width: double.infinity,
                child: Text(
                  'Введите код:',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: ColorConstants.grey03))),
              ),
              const PaddingTop(8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: () async {
                      await store.confirmEmail(
                          email: email, code: controller.text.trim());
                      Navigator.of(context).pop();
                    },
                    child: const Text('Подтвердить')),
              )
            ],
          ),
        ),
      ),
    );
  }
}
