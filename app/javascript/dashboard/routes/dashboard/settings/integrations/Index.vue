<template>
  <div class="column content-box">
    <div class="row">
      <div class="small-8 columns integrations-wrap">
        <div class="row integrations">
          <div
            v-for="item in integrationsList"
            :key="item.id"
            class="small-12 columns integration"
          >
            <integration
              :integration-id="item.id"
              :integration-logo="item.logo"
              :integration-name="item.name"
              :integration-description="item.description"
              :integration-enabled="item.enabled"
              :integration-action="item.action"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import { mapGetters } from 'vuex';
import Integration from './Integration';

export default {
  components: {
    Integration,
  },
  computed: {
    ...mapGetters({
      integrationsList: 'integrations/getIntegrations',
    }),
  },
  mounted() {
    this.$store.dispatch('integrations/get');
  },
};
</script>
