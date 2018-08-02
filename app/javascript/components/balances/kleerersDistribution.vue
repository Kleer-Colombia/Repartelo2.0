<template>
    <el-row :gutter="10" v-for="kleerer in distribution.kleerers" :key="kleerer.id" :id="'percentage_' + kleerer.name">
        <el-col :span="6">
            <el-checkbox-button
                    v-model="kleerer.selected"
                    :label="kleerer.id"
                    :key="kleerer.name"
                    :id="'check' + kleerer.name"
                    :disabled="!balance.editable"
                    @change="selectKleerer(kleerer)">
                <span>{{ kleerer.name }}</span> -
                <span style="font-size: 12px">{{ kleerer.option }}</span>
            </el-checkbox-button>
        </el-col>
        <el-col :offset="1" :span="8">
            <div v-show="kleerer.selected">
                <el-progress :percentage="kleerer.value" :stroke-width="15" style="margin-top: 12px;"></el-progress>
            </div>
        </el-col>
        <el-col :offset="1" :span="4">
            <div v-show="kleerer.selected">
                <el-input @change="formatValue(kleerer,$event)" v-model="kleerer.value"
                          :id="'inputPercentage' + kleerer.name" :disabled="!balance.editable">
                </el-input>
            </div>
        </el-col>
    </el-row>
</template>

<script>
    export default {
        name: "kleerers-distribution"
    }
</script>

<style scoped>

</style>