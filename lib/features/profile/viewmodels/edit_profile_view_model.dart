import 'package:seattap/core/base_view_model.dart';
import 'package:seattap/core/models/user_profile.dart';
import 'package:seattap/features/profile/data/edit_profile_repository.dart';
import 'package:seattap/features/profile/data/photo_service.dart';

/// UTM faculties offered on Edit profile.
const faculties = [
  'Faculty of Computing',
  'Faculty of Electrical Engineering',
  'Faculty of Mechanical Engineering',
  'Faculty of Civil Engineering',
  'Faculty of Chemical and Energy Engineering',
  'Faculty of Science',
  'Faculty of Built Environment and Surveying',
  'Faculty of Management',
  'Faculty of Social Sciences and Humanities',
];

/// Edit profile screen.
class EditProfileViewModel extends BaseViewModel {
  EditProfileViewModel(this.original, this._profiles, this._photos)
      : photoUrl = original.photoUrl,
        faculty = original.faculty;

  final UserProfile original;
  final EditProfileRepository _profiles;
  final PhotoService _photos;
  String? photoUrl;
  String? faculty;

  List<String> get facultyOptions => [
        ...faculties,
        if (original.faculty != null && !faculties.contains(original.faculty)) original.faculty!,
      ];

  void setFaculty(String? value) {
    faculty = value;
    notify();
  }

  Future<void> pickPhoto() async {
    String? picked;
    final ok = await run(() async => picked = await _photos.pickProfilePhoto());
    if (ok && picked != null) {
      photoUrl = picked;
      notify();
    }
  }

  void removePhoto() {
    photoUrl = null;
    notify();
  }

  Future<bool> save({required String name, required String phone}) => run(() => _profiles.updateProfile(
        original.uid,
        name: name.trim(),
        phone: phone.trim(),
        faculty: faculty,
        photoUrl: photoUrl,
      ));
}
