/// Maps weekday indexes between the producer-form UI and the backend API.
///
/// UI weekday: 0=Mon .. 6=Sun (matches the Seg..Dom chips).
/// API weekday: 0=Sun, 1=Mon .. 6=Sat.
class WeekdayMapper {
  const WeekdayMapper._();

  /// API weekday (0=Sun..6=Sat) -> UI index (0=Mon..6=Sun).
  static int toUi(int api) => api == 0 ? 6 : api - 1;

  /// UI index (0=Mon..6=Sun) -> API weekday (0=Sun..6=Sat).
  static int toApi(int ui) => ui == 6 ? 0 : ui + 1;
}
