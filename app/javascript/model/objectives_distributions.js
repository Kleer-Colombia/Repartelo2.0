export default {
    getInitialBalance() {
        if (!this.yearObjective.initial_balance_percentage) {
            return 'No hay porcentage inicial'
        }
        const lastObjective = this.objectives.find((objective) => {
            return objective.year === this.years.filteredYear - 1;
        }).actual.amount;

        const initialBalance = lastObjective * this.yearObjective.initial_balance_percentage * 0.01;
        return initialBalance

    },
    filterObjectives(objectives, year) {
        let objective

        try {
            objective = objectives.find((objective) => {
                return objective.year === year;
            }).actual;
        } catch (e) {
            objective = { amount: 'No hay metas disponibles para este año' }
        }

        return objective
    },
    findKleerersWithMeta(kleerers) {
        //TODO: we have to check if the kleerer has meta in this year
        const kleerersWithMeta = kleerers.filter(kleerer => {
            return kleerer.hasMeta;
        })

        return kleerersWithMeta
    },
    filterKleerers(data) {
        //percentage, yearObjective, objectivebykleerer, kleerers


        // const kleerersWithMeta = data.kleerers.filter(kleerer => {
        //     return kleerer.hasMeta;
        // }).length;

        // data.objectiveByKleerer = data.yearObjective.amount / kleerersWithMeta;

        const actualYear = data.filteredYear
        const lastYear = data.filteredYear - 1

        return data.kleerers
            .map((kleerer) => {

                let partialIncome = 0;
                let totalIncome = 0;
                let initialInput = 0

                if (kleerer.inputs.length !== 0) {
                    try {
                        if (kleerer.hasMeta) {
                            const lastInput = kleerer.inputs.find((input) => {
                                return input.year === lastYear;
                            }).input;

                            initialInput = (Number(lastInput) - Number(data.lastObjectiveByKleerer)) * data.initialBalancePercentage;

                            if (initialInput < 0 || isNaN(initialInput)) {
                                initialInput = 0
                            }
                        }
                    } catch (e) {
                        initialInput = 0;
                    }
                    try {
                        partialIncome = kleerer.inputs.find((input) => {
                            return input.year === actualYear;
                        }).input;
                        partialIncome = Number(partialIncome);
                    } catch (e) {
                        partialIncome = 0;
                    }
                    totalIncome = partialIncome + initialInput;
                }
                const anualMeta = kleerer.hasMeta ? data.formatPrice(data.objectiveByKleerer) : 'No tiene meta';

                const positiveBalance = kleerer.hasMeta ? (totalIncome - data.objectiveByKleerer > 0 ?
                        data.formatPrice(totalIncome - data.objectiveByKleerer) : data.formatPrice(0)) :
                    'No tiene meta';

                const outstandingBalance = kleerer.hasMeta ? (data.objectiveByKleerer - totalIncome > 0 ?
                        data.formatPrice(data.objectiveByKleerer - totalIncome) : data.formatPrice(0)) :
                    'No tiene meta';

                return {
                    name: kleerer.name,
                    inputFormat: data.formatPrice(partialIncome),
                    input: partialIncome,
                    initialInputFormat: kleerer.hasMeta ? data.formatPrice(initialInput) : 'No tiene meta',
                    initialInput: initialInput,
                    hasMeta: kleerer.hasMeta,
                    anualMeta: anualMeta ? anualMeta : 'No meta disponible',
                    positiveBalance: positiveBalance,
                    outstandingBalance: outstandingBalance
                };
            })
            .filter((kleerer) => {
                return kleerer.input !== 0 || kleerer.hasMeta;
            })
            .sort((a, b) => {
                return b.input - a.input;
            });
    }
}