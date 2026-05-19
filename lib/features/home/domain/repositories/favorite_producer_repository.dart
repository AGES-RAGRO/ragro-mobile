import 'package:ragro_mobile/features/home/domain/entities/favorite_producer.dart';

abstract class FavoriteProducerRepository {
  Future<List<FavoriteProducer>> getFavorites();
  Future<void> favoriteProducer(String producerId);
  Future<void> unfavoriteProducer(String producerId);
}
