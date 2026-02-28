# Cấu trúc thư mục dự án Book Reader (Flutter)

## 1 Cây thư mục tổng thể

<!-- ```text
book_reader_flutter/
├─ README.md
├─ STRUCTURE.md
├─ pubspec.yaml
├─ analysis_options.yaml
├─ .gitignore
├─ android/
├─ ios/
├─ web/                        # nếu bật đa nền tảng
├─ assets/
│  ├─ images/                  # ảnh UI, banner, cover mặc định
│  ├─ icons/                   # app icon, icons dùng trong app
│  ├─ fonts/                   # custom font (nếu có)
│  ├─ sample_data/             # dữ liệu mẫu (json) phục vụ demo/offline
│  └─ l10n/                    # đa ngôn ngữ (arb) nếu có
├─ docs/
│  ├─ 01_requirements/         # đặc tả yêu cầu, use case, user story
│  ├─ 02_analysis_design/      # phân tích & thiết kế (UML, ERD, kiến trúc)
│  ├─ 03_test_plan/            # kế hoạch test + test cases
│  ├─ 04_reports/              # báo cáo đồ án (lần 1, lần 2)
│  └─ 05_slides/               # slide thuyết trình/báo cáo nhóm
├─ screenshots/                # ảnh minh họa UI để đưa vào báo cáo/README
├─ scripts/                    # script build, generate (tùy chọn)
└─ lib/
   ├─ main.dart
   ├─ app.dart                 # cấu hình app: MaterialApp, routes, theme
   ├─ config/
   │  ├─ env.dart              # cấu hình môi trường (dev/prod)
   │  ├─ routes.dart           # khai báo route + tên route
   │  └─ theme/
   │     ├─ app_theme.dart
   │     └─ colors_typography.dart
   ├─ core/
   │  ├─ constants/            # hằng số: keys, strings, sizes...
   │  ├─ error/                # exception, failure, error mapping
   │  ├─ utils/                # helper: format, validators, extensions
   │  ├─ widgets/              # widget dùng chung: button/dialog/loading...
   │  └─ services/
   │     ├─ http/              # base http client, interceptors
   │     ├─ local_storage/     # shared_prefs/secure_storage wrapper
   │     └─ permissions/       # xin quyền (storage, media...) nếu cần
   ├─ data/
   │  ├─ datasources/
   │  │  ├─ local/
   │  │  │  ├─ sqlite/
   │  │  │  │  ├─ app_database.dart
   │  │  │  │  ├─ tables/      # định nghĩa bảng
   │  │  │  │  └─ dao/         # data access objects
   │  │  │  └─ file_cache/     # cache epub/pdf, cover, thumbnails
   │  │  └─ remote/
   │  │     ├─ api/            # REST API (books, categories, search...)
   │  │     └─ firebase/       # auth, firestore, storage, messaging...
   │  ├─ models/               # DTO/model map json <-> object
   │  └─ repositories/         # triển khai repository (data layer)
   ├─ domain/
   │  ├─ entities/             # thực thể: Book, Author, Bookmark...
   │  ├─ repositories/         # interface/abstract repository
   │  └─ usecases/             # nghiệp vụ: getBooks, openBook, sync...
   └─ presentation/
      ├─ state/                # quản lý state (bloc/cubit/provider/riverpod)
      ├─ pages/
      │  ├─ splash/
      │  ├─ auth/              # đăng nhập (nếu dùng Firebase auth)
      │  ├─ home/
      │  ├─ library/           # tủ sách
      │  ├─ book_detail/
      │  ├─ reader/            # màn đọc (epub/pdf), font size, theme...
      │  ├─ bookmarks/
      │  ├─ notes_highlights/  # ghi chú/đánh dấu (nếu có)
      │  ├─ search/
      │  └─ settings/
      └─ widgets/              # widget riêng theo feature (không dùng chung)
``` -->
