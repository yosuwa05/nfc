import 'dart:io';

import '../../entities/create_card_entity/create_card_entities.dart';
import '../../model/create_card_model/business_details_model/business_details_model.dart';
import '../../services/create_card_service/create_card_service.dart';

class CreateCardRepository {
final CreateCardService createCardService = CreateCardService();

  Future<BusinessDetailsModel> getBusinessDetail({
  required BusinessDetailsEntity businessDetailsEntity,
    required File? companyLogo,
    required String userId,
    }) async {
    return await createCardService.getBusinessDetails(
      businessDetailsEntity: businessDetailsEntity,
      userId: userId,
      companyLogo: companyLogo,
    );
  }
}