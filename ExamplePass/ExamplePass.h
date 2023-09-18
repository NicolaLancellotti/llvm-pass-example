#ifndef EXAMPLEPASS_H
#define EXAMPLEPASS_H

#include "llvm/IR/PassManager.h"

namespace llvm {

class ExamplePass : public PassInfoMixin<ExamplePass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &AM);
};

} // namespace llvm

#endif // EXAMPLEPASS_H
