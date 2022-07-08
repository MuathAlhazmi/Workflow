import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:workflow/helpers/responsive.dart';
import 'package:workflow/theme/colors.dart';

class CurrentMessage extends StatelessWidget {
  const CurrentMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(5),
        width: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.width * 0.6
            : MediaQuery.of(context).size.width * 0.4,
        height: 230,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) {
              return Divider(
                height: 10,
                color: mainColor,
              );
            },
            itemBuilder: (context, index) {
              return ListTile(
                trailing: Text(
                  index == 0
                      ? 'قبل ٦ دقائق'
                      : index == 1
                          ? 'قبل ٨ دقائق'
                          : 'قبل ١٠ دقائق',
                  style: TextStyle(color: mainColor, fontSize: 10),
                ),
                isThreeLine: false,
                title: Text(
                  index == 0
                      ? 'ارسلي الخط حق العنوان'
                      : index == 1
                          ? 'كيف التصميم عجبك ؟'
                          : 'خلصت تصميم الشعار ؟',
                  style: TextStyle(
                      color: mainColor, overflow: TextOverflow.ellipsis),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                leading: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: index == 0
                        ? 'https://mir-s3-cdn-cf.behance.net/project_modules/max_1200/57374d71284487.5bc0cf70dd323.png'
                        : index == 1
                            ? 'https://mir-s3-cdn-cf.behance.net/project_modules/max_1200/8b4e6871284487.5bbfb8d9d576a.png'
                            : 'https://mir-s3-cdn-cf.behance.net/project_modules/max_1200/7e02b371284487.5bbfb8d9d6165.png',
                    height: 60,
                    width: 60,
                  ),
                ),
              );
            }));
  }
}
