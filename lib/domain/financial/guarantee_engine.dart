class AgentExposure {
  const AgentExposure({required this.currentExposurePaise, required this.totalGuaranteeEventsPaise, required this.totalRecoveriesPaise});

  final int currentExposurePaise;
  final int totalGuaranteeEventsPaise;
  final int totalRecoveriesPaise;
}

class GuaranteeEngine {
  const GuaranteeEngine();

  AgentExposure calculate({required int expectedCollectionPaise, required int actualCollectionPaise, required int configuredGuaranteePaise, required int recoveryPaise}) {
    if (expectedCollectionPaise < 0 || actualCollectionPaise < 0 || configuredGuaranteePaise < 0 || recoveryPaise < 0) throw ArgumentError('Money values cannot be negative');
    final shortfall = expectedCollectionPaise > actualCollectionPaise ? expectedCollectionPaise - actualCollectionPaise : 0;
    final guarantee = shortfall < configuredGuaranteePaise ? shortfall : configuredGuaranteePaise;
    final exposure = guarantee > recoveryPaise ? guarantee - recoveryPaise : 0;
    return AgentExposure(currentExposurePaise: exposure, totalGuaranteeEventsPaise: guarantee, totalRecoveriesPaise: recoveryPaise);
  }
}
