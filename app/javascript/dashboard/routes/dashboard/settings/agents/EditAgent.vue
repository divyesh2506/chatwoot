<template>
  <modal :show.sync="show" :on-close="onClose">
    <div class="column content-box">
      <woot-modal-header :header-title="pageTitle" />
      <form class="row medium-8" @submit.prevent="editAgent()">
        <div class="medium-12 columns">
          <label :class="{ error: $v.agentName.$error }">
            {{ $t('AGENT_MGMT.EDIT.FORM.NAME.LABEL') }}
            <input
              v-model.trim="agentName"
              type="text"
              :placeholder="$t('AGENT_MGMT.EDIT.FORM.NAME.PLACEHOLDER')"
              @input="$v.agentName.$touch"
            />
          </label>
        </div>

        <div class="medium-12 columns">
          <label :class="{ error: $v.agentType.$error }">
            {{ $t('AGENT_MGMT.EDIT.FORM.AGENT_TYPE.LABEL') }}
            <multiselect
              v-model.trim="agentType"
              :options="agentTypeList"
              :placeholder="$t('AGENT_MGMT.EDIT.FORM.AGENT_TYPE.PLACEHOLDER')"
              :searchable="false"
              label="label"
              @select="setPageName"
            />
            <span v-if="$v.agentType.$error" class="message">
              {{ $t('AGENT_MGMT.EDIT.FORM.AGENT_TYPE.ERROR') }}
            </span>
          </label>
        </div>
        <div class="medium-12 modal-footer">
          <div class="medium-6 columns">
            <woot-submit-button
              :disabled="
                $v.agentType.$invalid ||
                  $v.agentName.$invalid ||
                  uiFlags.isUpdating
              "
              :button-text="$t('AGENT_MGMT.EDIT.FORM.SUBMIT')"
              :loading="uiFlags.isUpdating"
            />
            <button class="button clear" @click.prevent="onClose">
              {{ $t('AGENT_MGMT.EDIT.CANCEL_BUTTON_TEXT') }}
            </button>
          </div>
          <div class="medium-6 columns text-right">
            <button class="button clear" @click.prevent="resetPassword">
              <i class="ion-locked"></i>
              {{ $t('AGENT_MGMT.EDIT.PASSWORD_RESET.ADMIN_RESET_BUTTON') }}
            </button>
          </div>
        </div>
      </form>
    </div>
  </modal>
</template>

<script>
/* global bus */
/* eslint no-console: 0 */
import { required, minLength } from 'vuelidate/lib/validators';
import { mapGetters } from 'vuex';
import WootSubmitButton from '../../../../components/buttons/FormSubmitButton';
import Modal from '../../../../components/Modal';
import Auth from '../../../../api/auth';

export default {
  components: {
    WootSubmitButton,
    Modal,
  },
  props: {
    id: Number,
    name: String,
    email: String,
    type: String,
    onClose: Function,
  },
  data() {
    return {
      agentTypeList: this.$t('AGENT_MGMT.AGENT_TYPES'),
      agentName: this.name,
      agentType: {
        name: this.type,
        label: this.type,
      },
      agentCredentials: {
        email: this.email,
      },
      show: true,
    };
  },
  validations: {
    agentName: {
      required,
      minLength: minLength(4),
    },
    agentType: {
      required,
    },
  },
  computed: {
    pageTitle() {
      return `${this.$t('AGENT_MGMT.EDIT.TITLE')} - ${this.name}`;
    },
    ...mapGetters({
      uiFlags: 'agents/getUIFlags',
    }),
  },
  methods: {
    setPageName({ name }) {
      this.$v.agentType.$touch();
      this.agentType = name;
    },
    showAlert(message) {
      bus.$emit('newToastMessage', message);
    },
    async editAgent() {
      try {
        await this.$store.dispatch('agents/update', {
          id: this.id,
          name: this.agentName,
          role: this.agentType.name.toLowerCase(),
        });
        this.showAlert(this.$t('AGENT_MGMT.EDIT.API.SUCCESS_MESSAGE'));
        this.onClose();
      } catch (error) {
        console.log(error);
        this.showAlert(this.$t('AGENT_MGMT.EDIT.API.ERROR_MESSAGE'));
      }
    },
    async resetPassword() {
      try {
        await Auth.resetPassword(this.agentCredentials);
        this.showAlert(
          this.$t('AGENT_MGMT.EDIT.PASSWORD_RESET.ADMIN_SUCCESS_MESSAGE')
        );
      } catch (error) {
        this.showAlert(this.$t('AGENT_MGMT.EDIT.PASSWORD_RESET.ERROR_MESSAGE'));
      }
    },
  },
};
</script>
