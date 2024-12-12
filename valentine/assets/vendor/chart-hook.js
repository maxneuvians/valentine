import ApexCharts from 'apexcharts'

const Chart = {
    mounted() {
        const options = JSON.parse(this.el.dataset.options)
        let chart = new ApexCharts(this.el, options)
        chart.render()
    }
}

export default Chart;